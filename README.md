# Red Neuronal para Control de Iluminación Pública Inteligente

## 📋 Descripción

Red neuronal en MATLAB que analiza datos de comportamiento del tráfico en vías públicas para optimizar el control de iluminación (convencional y solar).

### Entradas
- **Hora del día** (0-23 horas)
- **Iluminación natural** (candelas/m²)
- **Cantidad de vehículos** (0-10 por carril, 3 carriles)
- **Velocidad promedio** (km/h, máx 100)

### Salidas
- **Control iluminación convencional**: 0 (apagado) - 1 (encendido)
- **Intensidad iluminación solar**: 0-100%

## 📊 Dataset

- **Período**: 24 horas completas
- **Frecuencia de muestreo**: Cada 15 minutos (96 muestras)
- **Carriles**: 3 carriles de vía pública
- **Máximo de vehículos por carril**: 10
- **Velocidad máxima**: 100 km/h

## 🧠 Arquitectura de la Red Neuronal

```
Entrada (4 neuronas)
    ↓
Capa oculta 1 (10 neuronas, ReLU)
    ↓
Capa oculta 2 (15 neuronas, ReLU)
    ↓
Salida (2 neuronas, Sigmoid)
```

**Tipo**: Feedforward
**Función de activación**: ReLU (capas ocultas), Sigmoid (salida)
**Optimizador**: Adam
**Épocas**: 500

## 📁 Estructura del Proyecto

```
prueba-red-neuronal/
├── README.md                    # Este archivo
├── .gitignore
├── script_completo.m           # ⭐ SCRIPT PRINCIPAL (TODO EN UNO)
├── main.m                      # Versión antigua (opcional)
├── data/
│   ├── generar_dataset.m       # (Opcional - incluido en script_completo)
│   └── dataset_24h.mat         # Se crea automáticamente
├── src/
│   ├── red_neuronal.m          # (Opcional - incluido en script_completo)
│   ├── validar_modelo.m        # (Opcional - incluido en script_completo)
│   └── resultados_validacion.mat
└── modelo_iluminacion.mat      # Modelo guardado (se crea al finalizar)
```

## 🚀 ¿CÓMO USAR? (LO MÁS IMPORTANTE)

### ⭐ OPCIÓN RECOMENDADA - Un solo script

**Abre MATLAB y ejecuta:**

```matlab
script_completo
```

¡Eso es todo! El script hará todo automáticamente:

1. ✅ **Genera el dataset** (24 horas cada 15 minutos)
2. ✅ **Entrena la red neuronal** (con progreso visual)
3. ✅ **Valida el modelo** (calcula métricas)
4. ✅ **Crea 4 figuras** con análisis detallados
5. ✅ **Guarda el modelo** (opcional al final)

### ⏱️ TIEMPO ESTIMADO

- **Generación de datos**: ~2-3 segundos
- **Entrenamiento**: ~30-60 segundos
- **Validación**: ~5 segundos
- **TOTAL**: ~1-2 minutos ⏰

### 📊 QUÉ VER DURANTE LA EJECUCIÓN

**Consola de MATLAB mostrará:**
```
╔═════════════════════════════════════════════════════════════╗
║     RED NEURONAL PARA ILUMINACIÓN PÚBLICA INTELIGENTE       ║
║          Script Completo: Datos - Entrenamiento - Validación║
╚═════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│ FASE 1: GENERANDO DATASET (24 HORAS)                       │
└─────────────────────────────────────────────────────────────┘
```

**Se abrirán 4 ventanas con gráficos:**

1. **Dataset - Análisis de 24 horas** (6 gráficos)
   - Iluminación natural vs hora
   - Tráfico vs hora
   - Velocidad vs hora
   - Control convencional
   - Intensidad solar
   - Relación entrada-salida

2. **Resultados de Entrenamiento** (2 gráficos)
   - Evolución de pérdida (entrenamiento vs validación)
   - Predicciones vs valores reales

3. **Análisis Detallado de Validación** (9 gráficos)
   - Distribuciones de errores
   - Scatter plots (real vs predicho)
   - Errores temporales
   - Residuos

4. **Predicciones Completas** (2 gráficos)
   - Control convencional completo
   - Intensidad solar completa

## 📈 SALIDA EN CONSOLA

Al finalizar verás:

```
╔═════════════════════════════════════════════════════════════╗
║                 RESUMEN FINAL DE RESULTADOS               ║
╠═════════════════════════════════════════════════════════════╣
║ SALIDA 1: CONTROL ILUMINACIÓN CONVENCIONAL                ║
╟─────────────────────────────────────────────────────────────╢
║ • MSE (Prueba): 0.xxx
║ • MAE (Prueba): 0.xxx
║ • RMSE (Prueba): 0.xxx
║ • Correlación: 0.xxxx
║ • Accuracy: 0.xxxx (xx.xx%)
║ • F1-Score: 0.xxxx
╠═════════════════════════════════════════════════════════════╣
║ SALIDA 2: INTENSIDAD ILUMINACIÓN SOLAR                    ║
╟─────────────────────────────────────────────────────────────╢
║ • MSE (Prueba): 0.xxx
║ • MAE (Prueba): 0.xxx
║ • RMSE (Prueba): 0.xxx
║ • Correlación: 0.xxxx
╚═════════════════════════════════════════════════════════════╝

¿Deseas guardar el modelo para uso futuro? (s/n):
```

## 🎯 ¿QUÉ SIGNIFICAN LAS MÉTRICAS?

| Métrica | Rango | Interpretación |
|---------|-------|----------------|
| **MSE** | 0 (mejor) | Error cuadrático medio - menor es mejor |
| **MAE** | 0 (mejor) | Error absoluto medio - menor es mejor |
| **RMSE** | 0 (mejor) | Raíz del error cuadrático - menor es mejor |
| **Correlación** | -1 a 1 | 1 = predicción perfecta, 0 = sin relación |
| **Accuracy** | 0 a 1 | Porcentaje de aciertos en clasificación |
| **F1-Score** | 0 a 1 | Balance entre precisión y recall |

## 📚 REQUISITOS EN MATLAB

**Asegúrate de tener instalados:**

1. ✅ **Deep Learning Toolbox** (o Neural Network Toolbox)
   ```matlab
   % Verificar:
   ver deep_learning
   % O
   ver neural_network
   ```

2. ✅ **MATLAB R2021b o superior**

3. ✅ **GPU (opcional)** - Acelera el entrenamiento

## 🔧 PERSONALIZAR EL SCRIPT

Si quieres modificar el comportamiento, edita estas líneas en `script_completo.m`:

```matlab
% Línea ~30: Cambiar número de muestras
horas_totales = 24;          % Cambiar a 48 para 2 días
minutos_intervalo = 15;      % Cambiar a 30 para intervalos más largos

% Línea ~138: Cambiar arquitectura de la red
hiddenLayerSize = [10, 15];  % Cambiar a [20, 30] para red más grande

% Línea ~150: Cambiar épocas de entrenamiento
'MaxEpochs', 500,            % Cambiar a 1000 para más épocas
'MiniBatchSize', 16,         % Cambiar a 32 para lotes más grandes
```

## ⚠️ SI ALGO SALE MAL

| Error | Solución |
|-------|----------|
| **Toolbox no encontrado** | Instala Deep Learning Toolbox desde Add-Ons |
| **Memoria insuficiente** | Reduce `horas_totales` o `MiniBatchSize` |
| **Red se entrena muy lento** | Reduce `MaxEpochs` a 200 |
| **Errores muy altos** | Aumenta `MaxEpochs` o cambia arquitectura |

## 📝 GUARDAR Y CARGAR EL MODELO

**Al finalizar, el script te pregunta:**
```
¿Deseas guardar el modelo para uso futuro? (s/n):
```

Si respondes `s` o `si`, se guarda como `modelo_iluminacion.mat`

**Para cargar después:**
```matlab
load('modelo_iluminacion.mat', 'net');

% Hacer predicción con nuevos datos
entrada = [12, 50, 5, 80];  % Ejemplo: hora 12, ilum 50, 5 veh, vel 80
salida = predict(net, entrada');
```

## 🎓 SOBRE EL PROYECTO

**Objetivo:** Prediseño de iluminación pública eficiente usando IA

**Características:**
- ✅ Dataset simulado pero realista
- ✅ Red neuronal con arquitectura optimizada
- ✅ Validación rigurosa con múltiples métricas
- ✅ Visualizaciones detalladas
- ✅ Documentación completa

## 📖 MÁS INFORMACIÓN

Para entender cómo funcionan los datos:
- Ver `script_completo.m` líneas 30-120 (generación de datos)
- Ver `script_completo.m` líneas 130-180 (arquitectura)
- Ver `script_completo.m` líneas 200-250 (validación)

## 👨‍💼 AUTOR

Proyecto académico - Iluminación Pública Eficiente con Inteligencia Artificial

## 📝 LICENCIA

MIT

---

**¡Listo para comenzar! Ejecuta `script_completo` en MATLAB y verás todo funcionar automáticamente.** 🚀
