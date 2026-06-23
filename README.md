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
Salida (2 neuronas, Sigmoid/Linear)
```

**Tipo**: Feedforward
**Función de activación**: ReLU (capas ocultas), Sigmoid/Linear (salida)
**Optimizador**: Adam o SGD

## 📁 Estructura del Proyecto

```
prueba-red-neuronal/
├── README.md
├── .gitignore
├── main.m
├── data/
│   ├── generar_dataset.m          # Generador de datos simulados
│   └── dataset_24h.mat            # Dataset guardado
└── src/
    ├── red_neuronal.m             # Definición y entrenamiento de la red
    └── validar_modelo.m           # Validación y métricas
```

## 🚀 Cómo usar

### Opción 1: Usar el script principal (Recomendado)
```matlab
main
```
Selecciona la opción que desees (generar datos, entrenar, validar o todo)

### Opción 2: Ejecutar scripts individuales

1. **Generar datos**:
   ```matlab
   cd data
   generar_dataset
   cd ..
   ```

2. **Entrenar la red neuronal**:
   ```matlab
   cd src
   red_neuronal
   cd ..
   ```

3. **Validar y visualizar**:
   ```matlab
   cd src
   validar_modelo
   cd ..
   ```

## 📊 Salidas esperadas

### Dataset
- Gráficos de comportamiento de 24 horas (iluminación, tráfico, velocidad)
- Relación entrada-salida
- Archivo: `data/dataset_24h.mat`

### Modelo
- Evolución de la pérdida de entrenamiento
- Comparación predicciones vs valores reales
- Archivo: `data/modelo_red_neuronal.mat`

### Validación
- Matrices de confusión
- Métricas: MSE, MAE, RMSE, Correlación, F1-Score
- Gráficos de residuos y análisis de errores
- Archivo: `src/resultados_validacion.mat`

## 📈 Métricas de Rendimiento

La red evalúa dos salidas independientes:

1. **Control Convencional** (Clasificación binaria)
   - Accuracy, Precision, Recall, F1-Score
   - Matriz de Confusión

2. **Intensidad Solar** (Regresión)
   - MSE, MAE, RMSE
   - Correlación de Pearson

## 📚 Requisitos

- **MATLAB** R2021b o superior
- **Neural Network Toolbox**
- **Signal Processing Toolbox** (opcional)
- **Statistics and Machine Learning Toolbox** (para gráficos avanzados)

## 🔧 Configuración de la Red

Puedes modificar en `src/red_neuronal.m`:

```matlab
% Cambiar arquitectura
hiddenLayerSize = [10, 15];  % Capas ocultas

% Cambiar hiperparámetros
'MaxEpochs', 500
'MiniBatchSize', 16
'LearnRateSchedule', 'piecewise'
```

## 📝 Licencia

MIT

---

**Proyecto académico**: Prediseño de iluminación pública eficiente con inteligencia artificial
