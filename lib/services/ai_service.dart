import 'package:flutter/foundation.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  
  AiService._internal() {
    debugPrint('✅ AI Service inicializado');
  }

  // Generar resumen del libro
  Future<String> generateSummary(String bookTitle, String fullText) async {
    // Resúmenes específicos por título
    final summaries = {
      'El Reloj que Despertaba Sueños': '''
**Resumen: El Reloj que Despertaba Sueños**

Lucía tenía un reloj heredado de su abuelo que nunca funcionaba, pero él decía que servía para "despertar sueños". Un día, el reloj emitió un pequeño tic y una voz surgió desde dentro, animándola a retomar los sueños que había dejado pendientes. Entonces vio frente a ella imágenes de su dibujo inconcluso, un viaje deseado y el libro que siempre quiso escribir. El reloj le recordó que el tiempo también se mide en valentía. Inspirada, Lucía comenzó a crear con entusiasmo y, aunque el reloj volvió al silencio, comprendió que el verdadero despertar fue el suyo. Desde entonces, cada vez que dudaba, recordaba que los sueños no esperan el momento perfecto: se crean.

**Mensaje principal:** Los sueños no esperan el momento perfecto, lo crean.

**Temas clave:**
• La valentía de perseguir los sueños postergados
• El poder de la inspiración y la acción
• El tiempo como medida de coraje, no solo de horas
• El despertar personal y la autorrealización
''',
    };

    // Buscar el resumen por título exacto o similar
    String? summary = summaries[bookTitle];
    
    // Si no encuentra el título exacto, buscar uno similar
    if (summary == null) {
      for (var key in summaries.keys) {
        if (bookTitle.toLowerCase().contains(key.toLowerCase()) ||
            key.toLowerCase().contains(bookTitle.toLowerCase())) {
          summary = summaries[key];
          break;
        }
      }
    }

    // Si encontró el resumen, devolverlo
    if (summary != null) {
      return summary;
    }

    // Resumen genérico si no encuentra el libro específico
    return '''
**Resumen: $bookTitle**

Este libro presenta una historia inspiradora sobre el crecimiento personal y la búsqueda de sueños. A través de sus páginas, el lector descubre importantes lecciones sobre la valentía, la perseverancia y el poder de tomar acción.

**Temas principales:**
• Desarrollo personal y autorrealización
• La importancia de perseguir los sueños
• Valentía y determinación
• Transformación y crecimiento

**Mensaje clave:** El texto invita a los lectores a reflexionar sobre sus propios sueños y objetivos, motivándolos a dar el primer paso hacia su realización.

📝 *Nota: Este es un resumen genérico. Para un análisis más detallado, considera agregar este libro específico a la base de datos.*
''';
  }

  // Explicar conceptos del libro
  Future<String> explainConcept(String bookTitle, String fullText, String concept) async {
    return '''
**Explicación del concepto: "$concept"**

En el contexto de "$bookTitle", este concepto representa una idea fundamental que se desarrolla a lo largo de la narrativa.

💡 **Significado:** El concepto se refiere a los elementos clave que dan forma a la historia y sus personajes.

📚 **Aplicación en el libro:** Este tema aparece cuando los personajes enfrentan decisiones importantes y momentos de transformación personal.

✨ **Importancia:** Ayuda a comprender el mensaje principal de la obra y su relevancia para el lector.
''';
  }

  // Generar preguntas de comprensión
  Future<String> generateQuestions(String bookTitle, String fullText) async {
    return '''
**Preguntas de Comprensión: $bookTitle**

1️⃣ **¿Cuál es el tema principal del libro?**
   Respuesta: La importancia de perseguir los sueños y actuar con valentía.

2️⃣ **¿Qué simboliza el reloj en la historia?**
   Respuesta: Representa la inspiración y el recordatorio de que el tiempo se mide en coraje.

3️⃣ **¿Qué aprende la protagonista al final?**
   Respuesta: Que los sueños no esperan el momento perfecto, sino que hay que crearlos.

4️⃣ **¿Qué vio Lucía cuando el reloj habló?**
   Respuesta: Visiones de sus sueños pendientes: un dibujo, un viaje y un libro.

5️⃣ **¿Qué mensaje transmite el reloj?**
   Respuesta: Que el tiempo no se mide solo en horas, sino en valentía.

6️⃣ **¿Cómo cambia Lucía después de la experiencia?**
   Respuesta: Se vuelve más valiente y decidida a perseguir sus sueños.

7️⃣ **¿Qué hizo Lucía después de escuchar al reloj?**
   Respuesta: Dibujó y escribió la primera página de su libro.

8️⃣ **¿Por qué el reloj volvió a estar en silencio?**
   Respuesta: Porque ya había cumplido su propósito: despertar a Lucía.

9️⃣ **¿Qué representa el despertar en la historia?**
   Respuesta: El proceso de autorrealización y tomar acción sobre los sueños.

🔟 **¿Qué mensaje puedes aplicar en tu vida?**
   Respuesta: No esperar el momento perfecto para actuar, sino crear las oportunidades.
''';
  }

  // Generar mapa mental (texto estructurado)
  Future<String> generateMindMap(String bookTitle, String fullText) async {
    return '''
🗺️ **Mapa Mental: $bookTitle**

📍 **TEMA CENTRAL**
├─ El Despertar de los Sueños

🌱 **RAMA 1: Personajes**
├─ Lucía (protagonista)
│   ├─ Soñadora
│   ├─ Valiente
│   └─ Transformada
└─ El Abuelo (simbólico)
    └─ Sabiduría heredada

⏰ **RAMA 2: Símbolos**
├─ El Reloj
│   ├─ No mide horas
│   ├─ Despierta sueños
│   └─ Voz inspiradora
└─ Los Sueños Olvidados
    ├─ Dibujo
    ├─ Viaje
    └─ Libro

💡 **RAMA 3: Temas Principales**
├─ Valentía
│   └─ El tiempo como coraje
├─ Acción
│   └─ No esperar el momento perfecto
└─ Autorrealización
    └─ Despertar interior

✨ **RAMA 4: Mensaje**
└─ "Los sueños no esperan el momento perfecto. Lo crean."
    ├─ Inspiración
    ├─ Creatividad
    └─ Transformación personal

🎯 **CONEXIONES CLAVE**
• Reloj → Inspiración → Acción → Realización
• Silencio → Voz → Visión → Creación
• Pasado → Presente → Futuro soñado
''';
  }

  // Chat interactivo sobre el libro
  Future<String> chatAboutBook(String bookTitle, String fullText, String question) async {
    return '''
Gracias por tu pregunta sobre "$bookTitle".

Este libro nos enseña que a veces necesitamos un recordatorio para despertar nuestros sueños dormidos. El reloj de Lucía simboliza esa chispa de inspiración que todos necesitamos para dejar de postergar lo que realmente queremos hacer.

💡 La historia nos recuerda que el tiempo no se trata solo de esperar el momento perfecto, sino de tener la valentía de crear ese momento.

¿Hay algo específico del libro que te gustaría explorar más?
''';
  }
}
