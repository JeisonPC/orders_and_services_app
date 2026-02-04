# Orders & Services App

Plataforma compuesta por dos microservicios Rails (`order_service` y `customer_service`) que colaboran para gestionar pedidos y clientes mediante mensajería con RabbitMQ y bases de datos Postgres aisladas. Este README centraliza la información necesaria para desarrollar, probar y desplegar el sistema.

## Arquitectura

![Espacio reservado para el diagrama](docs/Diagram_Orders_and_service_app.png)

[Consulta el diagrama completo en Figma](https://www.figma.com/board/vlndLcf3X90fskqIEB22Ai/Diagrama--Orders_and_service_app?node-id=0-1&t=gRiRmrMnu1SgIoZe-1).


## Tecnologías principales

- Ruby on Rails 7 (API mode) + RSpec/Minitest
- PostgreSQL 16 para persistencia por servicio
- RabbitMQ 3 (cola de eventos `order_created` y futuros tópicos)
- Docker Compose para orquestar los contenedores locales
- Kamal/Brakeman/Rubocop como herramientas incluidas en `bin/`

## Estructura rápida del repositorio

```
services/
  order_service/        API de pedidos, publica eventos
a customer_service/     API de clientes, consume eventos
  ...                   (ambos comparten layout Rails estándar)
docker-compose.yml      Orquestación local de bases, servicios y RabbitMQ
```

## Requisitos previos

1. Docker Desktop 4.x o compatible con Compose v2.
2. Make opcional, pero se recomienda tener `bash`/`zsh` y `direnv` para manejar variables si decides externalizarlas.
3. (Opcional) Ruby 3.2+ y bundler si quieres ejecutar los servicios fuera de Docker.

## Puesta en marcha con Docker Compose

```bash
git clone <repo>
cd orders_and_services_app
cp .env.example .env        # crea tus variables si es necesario
docker compose up --build   # levanta bases, RabbitMQ y APIs
```

- La API de pedidos queda expuesta en `http://localhost:3001`.
- La API de clientes responde en `http://localhost:3002`.
- RabbitMQ Management UI está en `http://localhost:15672` (guest/guest).
- Postgres para pedidos: puerto local `5433`; para clientes: `5434`.

Puedes seguir los logs de un servicio específico con `docker compose logs -f order_service` (o `customer_service`).

## Flujo de eventos

1. `order_service` procesa solicitudes REST y confirma un pedido.
2. Envia un evento `order_created` a RabbitMQ.
3. `customer_service` consume ese evento (ver `app/messaging/order_created_consumer.rb`) para sincronizar información adicional.

Las credenciales de RabbitMQ y el nombre de la cola se definen en las variables de entorno dentro del `docker-compose.yml`; modifícalas según el entorno destino.

## Trabajo por servicio

### Inicializar bases de datos

```bash
docker compose run --rm order_service bin/rails db:prepare
docker compose run --rm customer_service bin/rails db:prepare
```

### Ejecutar suites de pruebas

```bash
docker compose run --rm order_service bin/rspec
docker compose run --rm customer_service bin/rspec
# o utiliza minitest
docker compose run --rm customer_service bin/rails test
```

### Consolas Rails y tareas Rake

```bash
docker compose exec order_service bin/rails console
docker compose exec customer_service bin/rails console
```

Para tareas programadas o scripts personalizados, usa `docker compose exec <service> bin/rake <tarea>`.

## Variables de entorno relevantes

| Servicio            | Variable              | Descripción                                  |
| ------------------- | --------------------- | -------------------------------------------- |
| order_service       | `PORT`                | Puerto expuesto (default 3001)               |
| order_service       | `CUSTOMER_SERVICE_URL`| Endpoint interno para llamadas HTTP          |
| ambos               | `DB_HOST/DB_NAME/...` | Conexión a Postgres del servicio correspondiente |
| ambos               | `RABBITMQ_*`          | Host, puerto y credenciales para RabbitMQ    |

Coloca valores sensibles en `.env` (excluido del repo) y referencia ese archivo desde las configuraciones de Compose o credenciales Rails.

## Aseguramiento de la calidad

- `bin/rubocop` valida estilo Ruby en cada servicio.
- `bin/brakeman` inspecciona vulnerabilidades comunes.
- `bin/bundler-audit` revisa CVEs de dependencias.

Puedes ejecutar cualquiera de estas herramientas mediante `docker compose run --rm <service> bin/<tool>`.

## Despliegue

Cada servicio incluye scripts en `bin/` (como `bin/kamal`) y configuraciones en `config/deploy.yml` para despliegues containerizados. Ajusta las imágenes, variables y secretos por entorno antes de automatizar pipelines CI/CD.

## Troubleshooting rápido

| Problema | Posible causa/solución |
| -------- | ---------------------- |
| Migraciones no aplican | Revisa que el contenedor Postgres correspondiente esté corriendo y elimina datos persistidos con `docker volume rm` si necesitas un reset. |
| RabbitMQ no recibe eventos | Valida `RABBITMQ_HOST` dentro del contenedor (`docker compose exec order_service env`). |
| Cambios en código no reflejan | Verifica que los volúmenes `./services/...:/app` sigan montados y reinicia `docker compose restart <service>`. |