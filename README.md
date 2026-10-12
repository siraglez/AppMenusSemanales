# AppMenusSemanales 🍎🥗

> **Trabajo de Fin de Grado (TFG)**
> Aplicación nativa para iOS desarrollada con SwiftUI y SwiftData para la planificación automática de menús semanales saludables y la generación de la lista de la compra.

---

## 📋 Descripción

**AppMenusSemanales** ayuda a planificar de forma automática las comidas y cenas de toda la semana, teniendo en cuenta las preferencias y restricciones alimentarias de cada persona, y genera automáticamente la lista de la compra correspondiente.

La aplicación resuelve el esfuerzo diario de decidir qué cocinar mediante un algoritmo inspirado en la dieta mediterránea, que crea menús equilibrados, respeta alergias e intolerancias, evita repeticiones y calcula las cantidades reales que hay que comprar según el número de comensales.

---

## 🚀 Funcionalidades 

### Recetas
- Crear, editar y eliminar recetas con ingredientes (cantidad y unidad).
- Clasificación por tipo de ingesta (comida, cena o ambos) y estación (verano, invierno o ambas).
- Disponibilidad semanal: recetas para cualquier día, solo entre semana o solo fin de semana.
- Número de personas base para el que están escritas las cantidades.
- **Cálculo nutricional automático** (calorías, proteínas, carbohidratos y grasas) mediante la API de FoodData Centrar del USDA, con traducción de ingredientes al inglés usando Apple Translation.
- Detección automática de la categoría de la receta a partir de sus ingredientes.

### Generador de menús
- Algoritmo con **patrón mediterráneo** y optimización de macronutrientes (aproximadamente 20% proteínas, 50% carbohidratos, 30% grasas).
- Filtrado por estación.
- Exclusión de las recetas de la semana anterior para evitar repeticiones.
- Exclusión de alérgenos de todos los comensales.
- Respeto de la disponibilidad semanal de cada receta.
- **Recetas fijas**: asignar una receta concreta a un día e ingesta (ej.: pizza los viernes para cenar), que se coloca siempre automáticamente.
- Avisos claros cuando no hay suficientes recetas, con opción de generar igualmente.

### Preferencias alimentarias
- Tres niveles de restricción: **alergias** (excluyen la receta), **intolerancias** (la incluyen con aviso de adaptación) y **gustos** (aviso suave).
- Diccionario de ingredientes relacionados (ej.: "lactosa" detecta queso, nata, ...).

### Grupo familiar y espacios
- Varios miembros en la unidad familiar, cada uno con sus propias preferencias.
- Marca de "en casa" para decidir quine cuenta hoy en el menú y la compra.
- **Espacio familiar y espacio personal**: menús, recetario, recetas fijas y lista de la compra independientes para cada espacio.

### Lista de la compra
- Generación automática a partir del menú, escalando las cantidades según los comensales.
- Agrupación de ingredientes iguales.
- Productos manuales adicionales.
- Marcado de productos comprados, persistente entre sesiones.

### Sincronización y cuentas
- **Inicio de sesión con Apple** (Sign in with Apple).
- **Sincronización en la nube con CloudKit**: menús, recetas y listas compartidos y sincronizados en tiempo real entre dispositivos de la familia.

### Otros
- Tema claro, oscuro o según el sistema.
- Autenticación biométrica opcional (Face ID / Touch ID) para bloquear la app.

---

## 🛠 Stack Tecnológico

* **Lenguaje:** Swift
* **Framework de UI:** SwiftUI
* **Persistencia:** SwiftData (con sincronización CloudKit)
* **Arquitectura:** MVVM (Model-View-ViewModel)
* **Servicios:** API USDA FoodData Central, Apple Translation, CryptoKit, LocalAuthentication
* **Plataforma:** iOS 26.1+

---

## 📂 Estructura del Proyecto

El código fuente se organiza siguiendo el patrón MVVM:

* **Models:** Entidades de datos.
* **ViewModels:** Lógica de negocio.
* **Enums:** Enumeraciones compartidas.
* **Helpers:** Utilidades.
* **Views/Auth:** Acceso y configuración inicial.
* **Views/Recipes:** Recetas.
* **Views/Planning:** Planificador semanal y lista de la compra.
* **Views/Settings:** Perfil, ajustes, preferencias, grupo familiar.
* **Views/Components:** Componentes reutilizables.
* **AppMenusSemanalesApp:** Punto de entrada

---

## ⚙️ Instalación y Configuración
1. Clona el repositorio:
```bash
   git clone https://github.com/siraglez/AppMenusSemanales.git
```
2. Abre `AppMenusSemanales.xcodeproj` en Xcode.
3. **Configura la clave de la API del USDA.** La app necesita una clave gratuita
   de FoodData Central para el cálculo nutricional. Crea un archivo
   `Secrets.swift` (no incluido en el repositorio por seguridad) con este
   contenido:
```swift
   enum AppSecrets {
       static let usdaAPIKey = "TU_CLAVE_DE_LA_API"
   }
```
   Puedes obtener una clave en <https://fdc.nal.usda.gov/api-key-signup.html>.
4. Compila y ejecuta en el simulador o en un dispositivo con iOS 26.1 o superior.

> **Nota:** `Secrets.swift` está incluido en `.gitignore` para no exponer la
> clave. Nunca subas tu clave al repositorio.

---

## 📱 Uso

1. En la primera apertura, configura tus alergias, intolerancias y gustos.
2. Añade tus recetas desde la pestaña **Recetas**.
3. En el **Planificador**, elige el espacio (familiar o personal) y genera el
   menú de la semana.
4. Revisa la **Lista de la compra**, que se genera sola a partir del menú.
5. Gestiona tu perfil, grupo familiar y ajustes desde la pestaña **Perfil**.

---

## 🔒 Privacidad

Los datos de la aplicación se almacenan localmente en el dispositivo y, si el
usuario lo activa, se sincronizan de forma privada a través de su cuenta de
iCloud. La aplicación no comparte datos personales con terceros.

---

## 👤 Autora

* **Desarrolladora:** Sira Gonzalez-Madroño
* **Contexto:** Trabajo de Fin de Grado

--- 

## 📄 Licencia

Este proyecto se distribuye bajo los términos que determine la autora. Consulta
el archivo `LICENSE` si está disponible.
