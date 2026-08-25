# Especificación Técnica de Desarrollo: Plan M (OVTLYR) para Pine Script (v5)

Esta especificación describe la lógica técnica, fórmulas matemáticas y criterios de filtrado para implementar el **Plan M** de OVTLYR como un indicador o estrategia en **Pine Script (v5)** de TradingView. El Plan M es un sistema cuantitativo de seguimiento de tendencias con salidas holgadas (*looser exits*) diseñado para optimizar la relación riesgo-beneficio [78, 122].

---

## 1. Arquitectura de Filtros de Mercado y Sector (Macro Filtros)

Antes de generar señales en un activo individual, el script debe evaluar la salud general del mercado y la fortaleza relativa del sector. Si estas condiciones no se cumplen, las señales de entrada quedan desactivadas [104, 107].

### A. Filtro del Índice de Referencia (SPY)
*   **Condición:** El ETF SPY debe encontrarse en tendencia alcista estructurada y contar con una señal de compra activa de OVTLYR [104].

### B. Filtro de Sentimiento (Miedo y Codicia - Fear & Greed)
*   **Condición:** El indicador de sentimiento de mercado (Fear & Greed) debe estar **por debajo de 70 y en trayectoria ascendente** [104]. Un valor mayor a 70 o 75 indica sobreextensión extrema o complacencia masiva [104, 343].

### C. Amplitud del Mercado (Market Breadth)
*   **Condición:** El mercado debe presentar una amplitud netamente alcista (mayor número de acciones en tendencia alcista que bajista) [106]. Específicamente, el script debe rastrear el puntaje de canal OVTLYR, requiriendo un **valor de 2** para autorizar operaciones [106].
*   **Exclusiones Sectoriales:** Se descartan por completo sectores defensivos o con amplitud bajista, específicamente **Salud (Healthcare)** y **Servicios Públicos (Utilities)** [106, 107, 287].

### D. Codicia Relativa del Sector
*   **Condición:** El sector al que pertenece el activo debe tener un nivel de codicia superior al del mercado general [107]:
    $$\text{Greed}_{\text{Sector}} > \text{Greed}_{\text{SPY}}$$
    Además, la lectura de codicia del sector debe estar por debajo del límite de 70 y subiendo [107].

### E. Liquidez de la Acción
*   **Condición:** El activo a operar debe tener un volumen diario promedio mínimo [105, 143, 324]:
    $$\text{Volumen Promedio (20 días)} \ge 1,000,000 \text{ acciones}$$

---

## 2. Plantilla de Tendencia y Señales de Entrada (Entrada - BUY)

Cuando todos los macro filtros de la sección anterior son alcistas, el script evalúa el gráfico diario de la acción individual utilizando el **"Outlier Trend Template"** [63, 64].

### A. Alineación de Tendencia (Trend Template)
Las medias móviles exponenciales (EMA) y la media del precio deben estar alineadas de la siguiente manera en temporalidad diaria (o mensual en gráficos de largo plazo) [63, 64]:
1.  La **EMA de 10 períodos** (corto plazo) debe ser estrictamente mayor que la **EMA de 20 períodos** (mediano plazo) [64].
2.  El precio de cierre diario debe ser estrictamente mayor que la **media móvil de 50 períodos** (largo plazo, exponencial o simple) [64]:
    $$\text{EMA}_{10} > \text{EMA}_{20} \quad \text{y} \quad \text{Close} > \text{MA}_{50}$$

### B. Confirmación de Señal OVTLYR
*   **Condición:** Debe imprimirse una señal de compra ("Buy") oficial del sistema OVTLYR en el cierre de la vela diaria [64, 284].

### C. Filtro de Acción del Precio (Filtro de Mínimo Diario)
*   **Condición:** Para evitar comprar un activo que está perdiendo impulso estructural inmediato, el precio de entrada no puede estar por debajo del mínimo de la vela del día anterior [331]:
    $$\text{Precio de Entrada} > \text{Low}_{\text{Día Anterior}}$$

### D. Filtro de Zonas de Rechazo (Bloques de Órdenes / Outlier Blocks)
*   **Condición:** El script debe calcular e identificar los bloques de órdenes bajistas históricos (Outlier Blocks) [81].
*   **Regla de Exclusión:** No se permiten entradas si existe un bloque de órdenes bajista activo inmediatamente por encima del precio de entrada (dentro de un espacio menor a $2 \times \text{ATR}$ desde el precio de entrada) [331].
*   **Vigencia del Bloque:** Solo se consideran bloques con una antigüedad menor a **120 días calendario** [93, 97], a menos que se detecte un bloque de resistencia masiva e histórico muy relevante de largo plazo (por ejemplo, de años de antigüedad como el de marzo de 2022 o 2021) que deba ser evaluado de forma estricta [96, 99, 100].

---

## 3. Condiciones de Salida e Indicadores de Cierre (Salida - SELL)

El Plan M destaca por sus reglas de salida holgadas enfocadas en proteger la "familia" (el capital) y permitir que los ganadores corran de forma masiva [78, 122, 159, 166].

### A. Stop-Loss Inicial Basado en Volatilidad (2 ATR)
El stop-loss inicial innegociable se define utilizando la volatilidad promedio del activo determinada por el **Average True Range (ATR)** a 14 períodos [156, 172]:
$$\text{Stop-Loss Inicial} = \text{Precio de Entrada} - (2 \times \text{ATR}_{14})$$

### B. Stop Trailing Dinámico (Aseguramiento de Beneficios)
El stop-loss se desplaza de manera dinámica a medida que la operación avanza a favor del trade:
1.  **Dirección Única:** El stop-loss **solo se puede mover hacia arriba**. Bajo ninguna circunstancia se permite bajar el stop para dar "más aire" a una posición perdedora [154].
2.  **Lógica de Desplazamiento:** Cada vez que el activo sube una distancia equivalente a $1 \times \text{ATR}$ en dirección del trade, el stop-loss de 2 ATR se incrementa la misma distancia hacia arriba [86, 154, 342].

### C. Cruce de Medias Móviles (10/20 EMA Cross)
*   **Condición:** Si la EMA de 10 períodos realiza un cruce bajista por debajo de la EMA de 20 períodos, se genera una orden de salida automática al cierre de la vela que confirma el cruce [81, 82].

### D. Rechazo en Bloque de Órdenes Activo (Outlier Block)
*   **Condición:** Si el precio de la acción sube y entra en un bloque de órdenes bajista (resistencia histórica) de menos de 120 días y se observa rechazo/contracción en el gráfico intradía, la posición debe cerrarse de inmediato para asegurar ganancias [81, 93, 100]. Si el bloque es muy antiguo pero masivo (ej. >1000 días), no se debe sostener la posición si hay rechazo claro [99, 100].

### E. Regla de Escape: Gap and Crap
*   **Definición:** Ocurre cuando un activo abre con un hueco alcista (*gap up*), pero en lugar de sostener la subida, se desploma [79, 80].
*   **Lógica de Salida:** Si en cualquier momento de la operación (no solo en la entrada) el precio realiza un *gap up* y, dentro de las siguientes **3 velas diarias**, el precio de cierre cae por debajo del mínimo de la vela que originó el gap, se liquida la posición inmediatamente [79, 80].

### F. Salidas de Emergencia Intradía
1.  **Stop Inmediato de 3 ATR:** Si en cualquier momento de la sesión el precio del activo cae un equivalente a $3 \times \text{ATR}$ de volatilidad desde el precio de entrada, la posición se cierra inmediatamente a mercado sin esperar al cierre diario [129].
2.  **Filtro de la Mecha (Wick Low Alert):** Si el precio rompe a la baja un nivel clave de salida pero te quedas atrapado debido a la velocidad del mercado al cierre diario, se debe colocar un stop físico estricto en el mínimo de la mecha de ese día (*wick low*). Si al día siguiente el precio cotiza por debajo de este mínimo, se ejecuta la salida sin dilación [130].

---

## 4. Algoritmo de Gestión de Riesgo y Tamaño de la Posición

Un script que implemente el Plan M debe integrar el dimensionamiento dinámico de posición basado en la volatilidad de cada activo para mantener un riesgo idéntico en dólares en todo el portafolio [110, 156, 158].

### A. Fórmulas de Cálculo
1.  **Cálculo del Riesgo del Portafolio:**
    $$\text{Riesgo en USD} = \text{Capital de la Cuenta} \times \text{Porcentaje de Riesgo}$$
    *   *Nota:* Para cuentas nuevas o en aprendizaje se recomienda un porcentaje del **1%** [159, 166]. Para cuentas avanzadas operadas por Chris Uhl, se utiliza hasta un **6.25%** [112, 156, 157].

2.  **Cantidad de Acciones Equivalentes:**
    $$\text{Acciones Equivalentes} = \frac{\text{Riesgo en USD}}{2 \times \text{ATR}_{14}}$$
    Esto asegura que el riesgo en dólares sea exactamente el mismo sin importar si se opera una acción barata y de baja volatilidad o una acción de alta volatilidad [157, 183, 185].

3.  **Tamaño para Opciones Financieras (Contracts):**
    Si se decide apalancar la operación mediante contratos de opciones largas (Long Calls) en lugar de acciones al contado [137, 138]:
    $$\text{Número de Contratos} = \frac{\text{Acciones Equivalentes}}{\text{Delta del Contrato} \times 100}$$
    *   *Configuración predeterminada:* El delta objetivo del contrato debe ser fijado en **0.80** (Deep In-The-Money) [173, 335].

### B. Criterios de Selección de Opciones (Filtros de Contrato)
Para asegurar que el script de automatización o alerta seleccione el contrato adecuado, se deben codificar las siguientes reglas físicas:
*   **Vencimiento (DTE):** Entre **18 y 42 días calendario** hasta la fecha de vencimiento (con un objetivo ideal de 21 días) [136, 137]. Si faltan menos de 15 días para el vencimiento mensual actual, se debe buscar el vencimiento del mes siguiente [127, 336].
*   **Interés Abierto (Open Interest):** Mínimo de **250 a 300 contratos activos** en el strike seleccionado [87, 143, 313].
*   **Regla de Charlotte:** El strike adyacente superior (el strike al que se planea rodar la operación) también debe cumplir con un interés abierto líquido (mínimo de 250 a 300 contratos) antes de entrar al trade inicial [175, 336, 337].
*   **Bid-Ask Spread:** El diferencial entre las ofertas de compra y venta no debe superar los **50 centavos** o el **15% del costo de compra** del contrato [87, 337].
*   **Límite de Valor Extrínseco:** El valor extrínseco de la opción de compra (valor tiempo) no puede representar más del **25% al 30%** del costo total del contrato [87, 313, 337].

### C. Lógica de "Rodar" Contratos (Rolling Up)
*   Cuando la acción se mueve a favor del trade en múltiplos del ATR, en lugar de cerrar y tomar ganancias parciales, el script debe alertar para realizar un **Roll Up para crédito** [86, 120].
*   Se vende el contrato actual con alto delta y se compra simultáneamente el strike superior con delta de ~80 [86, 121, 122].
*   **Regla de oro:** Si la operación para rodar requiere un débito en lugar de un **crédito**, el script debe marcar un error de ejecución y detener la operación [91, 131].
