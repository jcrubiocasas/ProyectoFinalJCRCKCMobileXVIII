# TravelGuideAPI – Endpoints Documentados

Este documento describe todos los endpoints implementados en el backend de TravelGuideAPI, indicando si requieren autenticación JWT, su funcionalidad y ejemplos de uso con `curl`.

---

## 🔐 Endpoints protegidos por JWT

### 1. `GET /me`
**Descripción:** Devuelve los datos del usuario autenticado embebidos en el token JWT.

```bash
curl -X GET http://localhost:8080/me \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta esperada:**
```json
{
  "id": "UUID",
  "fullName": "Juan Carlos Rubio Casas",
  "isActive": true,
  "username": "jcrubio@equinsa.es"
}
```

---

### 2. `POST /ai/generate-itinerary`
**Descripción:** Solicita a ChatGPT la generación de un itinerario con imagen (DALL·E).

```bash
curl -X POST http://localhost:8080/ai/generate-itinerary \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "destination": "Granada",
    "maxVisitTime": 180,
    "maxResults": 1
}'
```

**Respuesta esperada:**
```json
[{
  "id": "UUID",
  "title": "La Alhambra",
  "description": "...",
  "duration": 120,
  "image": "/images/itineraries/UUID.png",
  "latitude": 37.176,
  "longitude": -3.5883
}]
```

---

### 3. `POST /itineraries/save`
**Descripción:** Guarda un itinerario generado en base de datos y lo asocia al usuario.

```bash
curl -X POST http://localhost:8080/itineraries/save \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '[{
    "id": "UUID",
    "title": "La Alhambra",
    "description": "...",
    "duration": 120,
    "image": "/images/itineraries/UUID.png",
    "latitude": 37.176,
    "longitude": -3.5883
}]'
```

**Respuesta esperada:**
```json
201 Created
```

---

### 4. `GET /itineraries/list`
**Descripción:** Lista todos los itinerarios almacenados por el usuario autenticado.

```bash
curl -X GET http://localhost:8080/itineraries/list \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta esperada:**
```json
[{
  "id": "UUID",
  "title": "La Alhambra",
  "description": "...",
  "duration": 120,
  "image": "/images/itineraries/UUID.png",
  "latitude": 37.176,
  "longitude": -3.5883
}]
```

---

### 5. `DELETE /itineraries/delete?id=UUID`
**Descripción:** Elimina un itinerario y su imagen asociada del servidor.

```bash
curl -X DELETE "http://localhost:8080/itineraries/delete?id=UUID" \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta esperada:**
```json
200 OK
```

---

## 🔓 Endpoints públicos (sin JWT)

### 6. `POST /auth/register`
**Descripción:** Registra un nuevo usuario.

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "nuevo@usuario.com",
    "password": "123456",
    "fullName": "Nuevo Usuario"
}'
```

**Respuesta esperada:**
```json
201 Created
```

---

### 7. `POST /auth/login`
**Descripción:** Autentica un usuario y retorna un JWT válido.

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "jcrubio@equinsa.es",
    "password": "123456"
}'
```

**Respuesta esperada:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

