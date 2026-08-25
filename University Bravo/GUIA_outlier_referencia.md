# GUÍA OUTLIER — Referencia Consolidada
### Filosofía, disciplina y ciclo de mercado del método de Christopher Uhl (Outlier University)
*Documento de síntesis — sustituye a `00_GUIA_OUTLIER_SYSTEM.md` + 3 PDFs originales (Herramienta de Clasificación Conductual, Metodología de Etapas, Política de Gestión de Riesgos), que quedan fuera de project knowledge por redundancia entre sí.*

---

## 0 · ALCANCE DE ESTE DOCUMENTO (leer primero)

Este documento recoge **solo la parte del sistema Outlier que es agnóstica del vehículo de inversión** — disciplina conductual, clasificación de operaciones, ciclo de mercado. Es aplicable igual si la entrada se ejecuta con acciones, ETFs u opciones.

**Deliberadamente fuera de este documento (no evaluado, no descartado — aparcado):**
- Todo lo relativo a **opciones deep-ITM, delta 0,80, rolls, Charlotte Rule, extrínseco/spread** (contenido de `plan_m_construccion_indicadores.md` y `especificacion-pine-script-plan-m.md`).
- La decisión de invertir con derivados **no se ha evaluado ni rechazado por mérito técnico**; simplemente no está en el alcance actual del proyecto. Si en el futuro Alex decide formarse en trading de opciones/derivados, ese bloque se retomará como **proyecto paralelo independiente**, no como extensión de este.
- Mientras tanto, `plan_m_construccion_indicadores.md` y la especificación Pine de Plan M **no se suben a project knowledge** de este proyecto.

Lo que sí sigue activo y en alcance: el **mecanismo de entrada/salida del Plan A** (Trend Template + score C1-C7, sin opciones) como overlay técnico — ya documentado en `plan_a_construccion_indicador.md`, que se sube aparte.

---

## 1 · FILOSOFÍA CORE

> *"Podrías publicar las reglas en un periódico y nadie las seguiría. La clave es consistencia y disciplina."* — Richard Dennis (Turtle Trader)

**Regla 90/90/90:** el 90% de los traders pierden el 90% de su capital en sus primeros 90 días. La causa no es falta de método, sino incapacidad de ejecutar el método con disciplina cuando el resultado individual es adverso.

**Idea central:** el éxito no se mide por el resultado de una operación individual (aleatorio), sino por la fidelidad al plan a lo largo de muchas operaciones (donde el edge estadístico, si existe, se manifiesta). Esto es coherente con el principio ya establecido en este proyecto de que *"las decisiones se juzgan contra el horizonte, no contra el ruido"* — aquí aplicado a nivel operación en vez de a nivel años.

---

## 2 · MATRIZ DE CLASIFICACIÓN DE OPERACIONES (Comportamiento × Resultado)

La idea clave: separar lo que controlas (seguir el plan) de lo que no controlas (el resultado que decide el mercado).

| | **Ganancia** | **Pérdida** |
|---|---|---|
| **Siguió el plan** | ✅ Buena operación ganadora — validación del sistema, sin euforia | ✅ Buena operación perdedora — stop ejecutado según reglas, capital protegido |
| **No siguió el plan** | ❌ Peligro — ganar rompiendo reglas refuerza hábitos que explotarán la cuenta a futuro | ❌❌ Fracaso conductual — sin plan y sin resultado |

**El caso más peligroso de los cuatro no es la pérdida sin plan — es la ganancia sin plan.** Enseña al cerebro que la indisciplina paga, lo cual es la vía más rápida a una pérdida grande futura. Vale la pena tenerlo presente incluso fuera de un sistema formal Outlier: cualquier operación (incluida una entrada fundamental) que salga bien "por casualidad" sin que la tesis se sostenga, merece la misma sospecha que una perdedora.

---

## 3 · LOS CUATRO RESULTADOS ACEPTABLES

El sistema exige eliminar un quinto resultado posible — la gran pérdida — dejando solo cuatro desenlaces permitidos:

1. **Gran ganancia** — se deja correr mientras la tendencia se sostiene.
2. **Pequeña ganancia** — se recogen beneficios parciales según objetivos predefinidos.
3. **Break even** — salida limpia, capital protegido.
4. **Pequeña pérdida** — stop respetado sin dudar.

**Prohibido por diseño:** la gran pérdida. La lógica no es evitar perder — es evitar que una sola pérdida sea lo bastante grande como para invalidar la esperanza matemática acumulada de las demás operaciones.

**Esperanza matemática (Expectancy):**
$$\text{Expectancy} = (\text{Win Rate} \times \text{Avg Win}) - (\text{Loss Rate} \times \text{Avg Loss})$$

Con expectancy positiva y suficientes operaciones, el resultado se vuelve estadísticamente predecible — igual que una moneda sesgada al 56-60% de cara no dice nada en 3 tiradas, pero sí en 1.000.

---

## 4 · EL CICLO DE MERCADO — LAS 4 ETAPAS

Marco de análisis de régimen (estilo Wyckoff), usado como contexto antes de evaluar cualquier entrada individual:

| Etapa | Fase | Psicología | Acción |
|---|---|---|---|
| **1** | Consolidación | Indecisión, equilibrio oferta/demanda | Observar — sin ventaja clara |
| **2** | Tendencia alcista | Codicia institucional | Comprar (zona de entrada del Plan A/M) |
| **3** | Distribución | El dinero institucional vende al minorista que entra por FOMO | Vender / tomar beneficios |
| **4** | Tendencia bajista | Miedo, pánico, capitulación | Prohibido comprar |

**Nota de fricción con el mandato del proyecto:** el sistema Outlier opera exclusivamente en Etapa 2 y evita activamente comprar en Etapa 4 ("no se discute con el precio"). Esto choca con la filosofía de calidad-a-descuento del proyecto, que sí puede justificar entrar en Etapa 1 o incluso 4 tardía si el fundamental lo sostiene. **Este marco de 4 etapas es útil como lectura de contexto técnico adicional, nunca como filtro que vete una entrada fundamentalmente sólida** — coherente con la regla ya existente en §6 sobre estacionalidad ("una mala temporada no veta una compra fundamentalmente sólida").

---

## 5 · REFERENCIAS CRUZADAS EN EL PROYECTO

| Tema | Documento | Estado |
|---|---|---|
| Racional de diseño Plan A (C1-C7, gate/score) | `plan_a_construccion_indicador.md` | ✅ En alcance — subir a project knowledge |
| Resultados backtest Plan A | `RESULTADOS_PLAN_A_backtest_v1.md` | Ya en project knowledge |
| Racional de diseño Plan M (con opciones) | `plan_m_construccion_indicadores.md` | ⏸️ Aparcado — no subir por ahora |
| Especificación Pine Plan M (con opciones) | `especificacion-pine-script-plan-m.md` | ⏸️ Aparcado — no subir por ahora |
| Matriz conductual + ciclo de mercado | Este documento | ✅ En alcance — sustituye a la GUIA + 3 PDFs originales |

---

*Documento de síntesis del proyecto. Fuente: transcripciones de Outlier University (Christopher Uhl). No es asesoramiento financiero.*
