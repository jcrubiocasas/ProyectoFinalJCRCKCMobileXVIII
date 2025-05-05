# 🌍 GPTravel - Guía Inteligente de Viajes

¡Bienvenido a GPTravel! 🚀  
Una app multiplataforma de turismo inteligente que te recomienda itinerarios personalizados mediante Inteligencia Artificial 🤖, imágenes reales 📷 y navegación en tiempo real 🗺️.

---

## ✨ Descripción del Proyecto

**GPTravel** es tu nueva app de turismo personalizada. Descubre lugares increíbles en base a tu ubicación y tiempo disponible. Combinamos IA (ChatGPT + DALL·E), Google Places API y tecnologías nativas de iOS y Android para crear una experiencia única:

🔎 Solicita rutas y lugares cercanos  
🧭 Navega con brújula y mapas  
📥 Guarda tus itinerarios favoritos  
📸 Visualiza imágenes reales + generadas  
🔒 Comparte tu ubicación en tiempo real con seguridad  
💡 Y mucho más...

---

## 🧠 Características Destacadas

| Funcionalidad                        | Descripción                                                                                                                                         |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| 🔐 **Login & Registro**              | Accede mediante usuario/contraseña o FaceID. Seguridad JWT integrada.                                                                              |
| 🧭 **Itinerarios inteligentes**      | Busca rutas indicando ciudad, tiempo y número de paradas. GPTravel genera resultados únicos gracias a ChatGPT y DALL·E.                             |
| 📍 **Mapa de navegación**            | Visualiza tu ubicación actual y navega hacia los puntos sugeridos.                                                                                 |
| 🗺️ **Direcciones en tiempo real**    | Trazo de rutas usando Google Directions API y visualización con GMSPolyline.                                                                      |
| 📦 **Guardado en local + backend**   | Sincroniza tus itinerarios guardados para usarlos incluso después de reinstalar la app.                                                             |
| 🎯 **Brújula dinámica**              | Visualiza la dirección y distancia al destino turístico desde tu ubicación actual.                                                                 |
| 📷 **Imágenes enriquecidas**         | Combinamos imágenes generadas por IA (DALL·E) y reales (Google Places).                                                                            |
| 📊 **Publicidad basada en GPS**      | Sistema de banners turísticos personalizados según tu ubicación.                                                                                   |
| 🔒 **Compartir ubicación segura**    | Comparte tu posición en tiempo real con alguien de confianza mediante un enlace cifrado de acceso único.                                           |
| ⚙️ **Modo oscuro & ajustes**         | Interfaz moderna con soporte para temas y configuración personalizada.                                                                             |

---

## 📲 Capturas de Pantalla (Mockups)

> ⚠️ Sustituye los enlaces por imágenes reales o de Figma si están disponibles

### 🧭 Home: Buscar itinerario avanzado
![Buscar itinerario](https://via.placeholder.com/300x600?text=Buscar+Itinerario)

### 💾 Guardados
![Itinerarios guardados](https://via.placeholder.com/300x600?text=Guardados)

### 🗺️ Mapa y Navegación
![Mapa con rutas](https://via.placeholder.com/300x600?text=Mapa+%26+Navegacion)

### 🧭 Brújula y distancia
![Brújula](https://via.placeholder.com/300x600?text=Br%C3%BAjula)

### 🔒 Compartir ubicación segura
![Compartir ubicación](https://via.placeholder.com/300x600?text=Ubicacion+Segura)

---

## 🧭 Guía de Uso Rápido

### 1. Registro / Login
- Crea tu cuenta o inicia sesión con FaceID si está activado.
- Se genera un token JWT seguro que permite acceder a las funcionalidades del backend.

### 2. Buscar Itinerario
- Ve a la pestaña **"Buscar"**.
- Introduce tu ciudad de destino, tiempo disponible y número de paradas.
- Recibirás un itinerario enriquecido con:
  - Nombre del lugar
  - Imagen AI y real
  - Descripción extensa
  - Contacto, horarios, ubicación GPS

### 3. Guardar / Descartar
- Puedes **guardar** el itinerario (se almacena localmente y en el backend).
- O puedes **descartarlo** y realizar otra búsqueda.

### 4. Ver Guardados
- En la pestaña **"Guardados"**, verás todos tus itinerarios almacenados.
- Puedes eliminarlos o acceder a funciones adicionales como brújula o navegador.

### 5. Mapa
- En **"Mapa"**, verás tu posición y los destinos turísticos.
- Trazo de rutas con Google Directions API.
- Pulsando un marcador, accedes al itinerario.

### 6. Brújula
- Desde la vista del itinerario, abre la brújula.
- Te indica la dirección al destino y la distancia exacta.

### 7. Compartir Ubicación en Tiempo Real
- Desde ajustes o el mapa, activa **"Compartir ubicación"**.
- Se generará un enlace único y temporal.
- Cópialo y compártelo por cualquier canal seguro.
- El receptor verá tu posición actual en tiempo real, sin necesidad de tener GPTravel.

---

## 🔒 Compartir ubicación segura (detalle)

GPTravel incluye una funcionalidad opcional de seguridad que permite compartir tu ubicación en tiempo real con alguien de confianza.

### 🔗 ¿Cómo funciona?

1. Activa la opción desde el menú de ajustes o el mapa.
2. Se genera un enlace único, seguro y cifrado:
3. El enlace puede compartirse por cualquier medio: SMS, email, WhatsApp...
4. El receptor verá un mapa con tu posición actual (actualizada cada 30 segundos).
5. Puedes desactivar el enlace en cualquier momento.

### 🛡️ Seguridad implementada

- Cifrado extremo a extremo y tokens temporales.
- Expiración automática configurable (por ejemplo: 30 min, 1 h).
- No se almacena el histórico de posiciones.
- El enlace no es indexable ni reutilizable.

---

## 🧰 Tecnologías Utilizadas

### 📱 iOS App (Swift + SwiftUI)
- `MVVM` + `Combine` + `SOLID`
- `Alamofire` para llamadas HTTP
- `SDWebImageSwiftUI` para mostrar imágenes remotas
- `CoreLocation` y `MapKit` para mapas, brújula y tracking
- `SwiftData` para persistencia local

### 🌐 Backend (Vapor)
- API RESTful en Swift
- Autenticación JWT con Middleware
- OpenAI (ChatGPT + DALL·E) para descripciones e imágenes
- Google Places API para datos reales
- PostgreSQL como base de datos
- Compartir ubicación con enlaces cifrados y token temporales
- Estructura en carpetas: `Controllers`, `Services`, `Models`, `DTOs`, `Migrations`, `Middlewares`

### ☁️ Hosting y despliegue
- Servidor en entorno Linux
- Exposición por IP fija: `http://dev.equinsaparking.com:10605`

---

## 🧭 Arquitectura General

```text
Frontend (iOS)                     Backend (Vapor)
-------------------------          -----------------------------
AdvancedItineraryViewModel   →    GPTService / DALL·E
MapViewModel                →     GooglePlacesService
SavedItinerariesViewModel   →     ItineraryController / AdvancedItineraryController
CompassViewModel            →     (solo lógica local)
🔒 LocationShareService      →     LocationShareController + TokenManager


🛠️ Instalación y Ejecución

🔧 Backend (Vapor)
git clone https://github.com/jcrubiocasas/ProyectoFinalJCRCKCMobileXVIII.git
cd ProyectoFinalJCRCKCMobileXVIII/TravelGuideAPI
cp .env.example .env
# Configura claves de API: OPENAI_KEY, UNSPLASH_KEY, DATABASE_URL, etc.
vapor xcode
open Package.swift
# Ejecuta desde Xcode o terminal:
vapor run

📱 iOS App
git clone https://github.com/jcrubiocasas/ProyectoFinalJCRCKCMobileXVIII.git
cd ProyectoFinalJCRCKCMobileXVIII/GPTravel IOS
open GPTravel.xcodeproj
# Configura URL del backend en archivo `Constants.swift`
# Ejecuta en simulador o dispositivo físico


🙌 Créditos y Agradecimientos
    •    🧠 OpenAI (ChatGPT & DALL·E)
    •    📷 Google Places API
    •    🌍 Apple MapKit
    •    🛠 KeepCoding Bootcamp XVIII
    •    👩‍💻 Proyecto desarrollado por:
Juan Carlos Rubio Casas
Bootcamp Mobile 18 - Guardia imperial

💬 Contacto

📧 Email: jcrubio@equinsa.es
🔗 GitHub: @jcrubiocasas

