# TravelGuideAPI

**Guía Inteligente de Viajes - Backend en Vapor (Swift)**

Este proyecto forma parte del Bootcamp XVIII de KeepCoding y representa el backend completo de una app de rutas turísticas inteligentes. El sistema combina inteligencia artificial (ChatGPT + DALL·E), Google Places, y datos en tiempo real, con una arquitectura robusta basada en Vapor (Swift), persistencia en PostgreSQL y autenticación JWT. Las funcionalidades incluyen registro/login, generación de itinerarios turísticos, almacenamiento personalizado, historial de búsquedas y sistema de publicidad contextual.

---

## 📌 Descripción del Proyecto

TravelGuideAPI es una RESTful API diseñada para generar, almacenar y mostrar rutas turísticas personalizadas. A través de inteligencia artificial, la API sugiere lugares de interés según tiempo disponible y ubicación. Las imágenes se generan con DALL·E o se recuperan desde Google Places. Todos los datos son persistidos en PostgreSQL y están protegidos por JWT.

El sistema se ha desarrollado siguiendo el patrón MVVM y los principios SOLID para asegurar una arquitectura clara, desacoplada y escalable.

---

## 🧱 Organización del Proyecto

El proyecto sigue una estructura MVVM adaptada al entorno backend con Vapor. La estructura modularizada permite una clara separación de responsabilidades, facilitando la escalabilidad, testeo y mantenibilidad.

```
TravelGuideAPI/
├── Public/                      # Archivos estáticos (imágenes DALL·E)
├── Resources/                   # Plantillas y recursos
├── Sources/
│   └── App/
│       ├── Controllers/         # Entrada de peticiones HTTP (View)
│       ├── Models/              # Modelos de base de datos (Model)
│       ├── Services/            # Lógica de negocio y coordinación (ViewModel)
│       ├── DTOs/                # Estructuras para comunicación (Request/Response)
│       ├── Migrations/          # Creación de tablas y estructuras DB
│       ├── Middlewares/         # JWT, autenticación, CORS, validadores
│       ├── Config/              # Configuración del entorno
│       ├── Routes/              # Registro y agrupación de rutas
│       └── main.swift           # Punto de entrada principal
├── Tests/
│   └── AppTests/                # Pruebas unitarias
├── .env                         # Variables de entorno y secretos
├── Package.swift                # Definición de dependencias
└── README.md                    # Documentación del proyecto
```

---

## 🗄️ Tablas de Base de Datos

### `users`

Contiene los datos de autenticación y perfil del usuario.

| Campo        | Tipo   | Descripción           |
| ------------ | ------ | --------------------- |
| id           | UUID   | Identificador único   |
| fullName     | String | Nombre completo       |
| email        | String | Email único           |
| passwordHash | String | Contraseña encriptada |
| isActive     | Bool   | Activación por email  |
| createdAt    | Date   | Fecha de creación     |

**Usado en:** autenticación (`/auth/*`), activación, gestión de JWT, login

---

### `itineraries`

Itinerarios generados por ChatGPT + DALL·E, sin datos externos.

| Campo       | Tipo   | Descripción                        |
| ----------- | ------ | ---------------------------------- |
| id          | UUID   | Identificador                      |
| title       | String | Nombre del lugar                   |
| description | Text   | Descripción generada               |
| duration    | String | Tiempo estimado de visita          |
| image       | String | Ruta imagen DALL·E (`/images/...`) |
| latitude    | Double | Coordenadas GPS                    |
| longitude   | Double | Coordenadas GPS                    |
| userId      | UUID   | Referencia al `user.id`            |

**Usado en:** generación (`/ai/generate-itinerary`), guardado y listado `/itineraries/*`

---

### `advanced_itineraries`

Contiene itinerarios enriquecidos con datos reales de Google Places.

| Campo       | Tipo   | Descripción                      |
| ----------- | ------ | -------------------------------- |
| id          | UUID   | Identificador único              |
| title       | String | Nombre real del lugar            |
| description | Text   | Descripción (IA)                 |
| duration    | String | Duración sugerida                |
| imageAI     | String | Imagen DALL·E                    |
| imageReal   | String | Imagen real (Google)             |
| address     | String | Dirección completa               |
| phone       | String | Teléfono de contacto             |
| website     | String | URL del sitio oficial            |
| latitude    | Double | Coordenadas                      |
| longitude   | Double | Coordenadas                      |
| source      | String | Fuente (Google / GPT)            |
| category    | String | Tipo de lugar (museo, parque...) |
| userId      | UUID   | Usuario que lo guardó            |

**Usado en:** `/ai/generate-advanced-itinerary`, `/advanced-itineraries/*`

---

### `search_history`

Historial de búsquedas por usuario. Controla resultados previos y evita repeticiones.

| Campo     | Tipo   | Descripción              |
| --------- | ------ | ------------------------ |
| id        | UUID   | Identificador            |
| userId    | UUID   | Usuario al que pertenece |
| title     | String | Nombre lugar sugerido    |
| createdAt | Date   | Fecha de búsqueda        |

**Usado en:** enriquecimiento del prompt IA, prevención de resultados duplicados.

---

### `ads`

Tabla de anuncios geolocalizados (opcional si se almacenan en BD).

| Campo       | Tipo   | Descripción             |
| ----------- | ------ | ----------------------- |
| id          | UUID   | Identificador           |
| image       | String | URL imagen publicitaria |
| latitude    | Double | Centro geográfico       |
| longitude   | Double | Centro geográfico       |
| radiusKm    | Double | Radio de activación     |
| description | String | Texto del anuncio       |

**Usado en:** `/ads/banner` según coordenadas actuales del usuario.

---

## 🚀 Endpoints y pruebas

### 🔐 AUTENTICACIÓN JWT

#### `POST /auth/register`

Registra un nuevo usuario. Por defecto, estará inactivo hasta confirmar su email.

**Body JSON:**

```json
{
  "fullName": "Juan Pérez",
  "email": "juan@example.com",
  "password": "123456"
}
```

**cURL:**

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Juan Pérez", "email":"juan@example.com", "password":"123456"}'
```

---

#### `POST /auth/login`

Devuelve un JWT si las credenciales son válidas y la cuenta está activa.

**Body JSON:**

```json
{
  "email": "juan@example.com",
  "password": "123456"
}
```

**cURL:**

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"juan@example.com", "password":"123456"}'
```

---

#### `GET /auth/me`

Obtiene los datos del usuario autenticado.

**cURL:**

```bash
curl http://localhost:8080/auth/me \
  -H "Authorization: Bearer TU_TOKEN"
```

---

#### `GET /auth/activate?token=...`

Activa una cuenta con el token enviado por email.

**cURL:**

```bash
curl http://localhost:8080/auth/activate?token=TOKEN_AQUI
```

---

#### `DELETE /auth/delete`

Elimina la cuenta del usuario autenticado.

**cURL:**

```bash
curl -X DELETE http://localhost:8080/auth/delete \
  -H "Authorization: Bearer TU_TOKEN"
```

---

### 📍 ITINERARIOS BÁSICOS (IA + DALL·E)

#### `POST /ai/generate-itinerary`

Genera un itinerario con ChatGPT y una imagen con DALL·E.

**Body JSON:**

```json
{
  "destination": "Barcelona",
  "timeAvailable": "5 horas",
  "maxResults": 1
}
```

**cURL:**

```bash
curl -X POST http://localhost:8080/ai/generate-itinerary \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"destination":"Barcelona","timeAvailable":"5 horas","maxResults":1}'
```

---

#### `POST /itineraries/save`

Guarda un itinerario en base de datos.

**Body JSON:**

```json
{
  "id": "uuid-del-itinerario",
  "title": "Sagrada Familia",
  "description": "Una basílica impresionante...",
  "duration": "90 minutos",
  "latitude": 41.4036,
  "longitude": 2.1744,
  "image": "/images/itineraries/uuid.png"
}
```

**cURL:**

```bash
curl -X POST http://localhost:8080/itineraries/save \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

---

#### `GET /itineraries/list`

Lista los itinerarios guardados por el usuario.

**cURL:**

```bash
curl http://localhost:8080/itineraries/list \
  -H "Authorization: Bearer TU_TOKEN"
```

---

### 💎 ITINERARIOS AVANZADOS (IA + Google Places)

#### `POST /ai/generate-advanced-itinerary`

Genera un itinerario enriquecido con IA + datos reales.

**Body JSON:** igual que en `/generate-itinerary`

**Respuesta:** incluye nombre, dirección, horario, teléfono, sitio web, imagen real y generada.

**cURL:**

```bash
curl -X POST http://localhost:8080/ai/generate-advanced-itinerary \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"destination":"Barcelona","timeAvailable":"5 horas","maxResults":1}'
```

---

#### `POST /advanced-itineraries/save`

Guarda un itinerario avanzado.

**Body JSON:** igual a los campos enriquecidos de la respuesta del endpoint anterior.

---

#### `GET /advanced-itineraries/list`

Lista los itinerarios avanzados guardados.

**cURL:**

```bash
curl http://localhost:8080/advanced-itineraries/list \
  -H "Authorization: Bearer TU_TOKEN"
```

---

#### `DELETE /advanced-itineraries/{id}`

Borra un itinerario avanzado por ID.

**cURL:**

```bash
curl -X DELETE http://localhost:8080/advanced-itineraries/UUID \
  -H "Authorization: Bearer TU_TOKEN"
```

---

### 📢 PUBLICIDAD GEOLOCALIZADA

#### `POST /ads/banner`

Devuelve un anuncio en función de la localización.

**Body JSON:**

```json
{
  "latitude": 41.4,
  "longitude": 2.1
}
```

**cURL:**

```bash
curl -X POST http://localhost:8080/ads/banner \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"latitude":41.4,"longitude":2.1}'
```


