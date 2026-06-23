%% RED NEURONAL PARA CONTROL DE ILUMINACIÓN PÚBLICA
% Arquitectura: 4 entradas -> 10 neuronas (oculta 1) -> 15 neuronas (oculta 2) -> 2 salidas
% Entrenamiento con Neural Network Toolbox de MATLAB

clear all; close all; clc;

%% CARGAR DATASET
fprintf('Cargando dataset...\n');
load('dataset_24h.mat', 'X', 'Y');

fprintf('✓ Dataset cargado correctamente\n');
fprintf('  Entradas (X): %d x %d\n', size(X, 1), size(X, 2));
fprintf('  Salidas (Y): %d x %d\n', size(Y, 1), size(Y, 2));

%% DIVIDIR EN CONJUNTOS DE ENTRENAMIENTO, VALIDACIÓN Y PRUEBA
% 70% Entrenamiento, 15% Validación, 15% Prueba
num_muestras = size(X, 1);
indices = randperm(num_muestras);

train_idx = indices(1:round(0.7*num_muestras));
val_idx = indices(round(0.7*num_muestras)+1:round(0.85*num_muestras));
test_idx = indices(round(0.85*num_muestras)+1:end);

X_train = X(train_idx, :)';
Y_train = Y(train_idx, :)';

X_val = X(val_idx, :)';
Y_val = Y(val_idx, :)';

X_test = X(test_idx, :)';
Y_test = Y(test_idx, :)';

fprintf('\n=== DIVISIÓN DEL DATASET ===\n');
fprintf('Entrenamiento: %d muestras (70%%)\n', length(train_idx));
fprintf('Validación: %d muestras (15%%)\n', length(val_idx));
fprintf('Prueba: %d muestras (15%%)\n', length(test_idx));

%% CREAR RED NEURONAL
fprintf('\n=== CREANDO RED NEURONAL ===\n');

% Arquitectura: 4 entrada -> 10 (oculta) -> 15 (oculta) -> 2 (salida)
hiddenLayerSize = [10, 15];
net = fitnetwork(4, hiddenLayerSize, 2, 'trainlm');

%% CONFIGURAR RED
% Función de activación
net.hiddenConnections(1).transferFcn = 'relu';  % Capa oculta 1
net.hiddenConnections(2).transferFcn = 'relu';  % Capa oculta 2
net.outputConnections.transferFcn = 'sigmoid';  % Capa salida (para [0,1])

% Opciones de entrenamiento
options = trainingOptions('adam', ...
    'MaxEpochs', 500, ...
    'MiniBatchSize', 16, ...
    'ValidationData', {X_val, Y_val}, ...
    'ValidationFrequency', 10, ...
    'ValidationPatience', 50, ...
    'Verbose', 1, ...
    'Plots', 'training-progress', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 100, ...
    'LearnRateDropFactor', 0.5);

fprintf('Configuración de entrenamiento:\n');
fprintf('  Optimizador: Adam\n');
fprintf('  Épocas máximas: 500\n');
fprintf('  Tamaño de lote: 16\n');
fprintf('  Función de activación (oculta): ReLU\n');
fprintf('  Función de activación (salida): Sigmoid\n');

%% ENTRENAR RED
fprintf('\n=== INICIANDO ENTRENAMIENTO ===\n');
tic;
[net, info] = trainNetwork(X_train, Y_train, net, options);
tiempo_entrenamiento = toc;

fprintf('\n✓ Entrenamiento completado en %.2f segundos\n', tiempo_entrenamiento);

%% REALIZAR PREDICCIONES
fprintf('\n=== EVALUANDO MODELO ===\n');

% Predicciones en cada conjunto
Y_pred_train = predict(net, X_train);
Y_pred_val = predict(net, X_val);
Y_pred_test = predict(net, X_test);

% Calcular Error Cuadrático Medio (MSE)
mse_train = mean((Y_pred_train - Y_train).^2, 'all');
mse_val = mean((Y_pred_val - Y_val).^2, 'all');
mse_test = mean((Y_pred_test - Y_test).^2, 'all');

% Calcular Error Absoluto Medio (MAE)
mae_train = mean(abs(Y_pred_train - Y_train), 'all');
mae_val = mean(abs(Y_pred_val - Y_val), 'all');
mae_test = mean(abs(Y_pred_test - Y_test), 'all');

fprintf('Error Cuadrático Medio (MSE):\n');
fprintf('  Entrenamiento: %.6f\n', mse_train);
fprintf('  Validación: %.6f\n', mse_val);
fprintf('  Prueba: %.6f\n', mse_test);

fprintf('\nError Absoluto Medio (MAE):\n');
fprintf('  Entrenamiento: %.6f\n', mae_train);
fprintf('  Validación: %.6f\n', mae_val);
fprintf('  Prueba: %.6f\n', mae_test);

%% VISUALIZAR RESULTADOS DE ENTRENAMIENTO
figure('Name', 'Resultados de Entrenamiento', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);

% Gráfico 1: Pérdida de entrenamiento vs validación
subplot(1, 2, 1);
plot(info.TrainingLoss, 'b-', 'LineWidth', 2, 'DisplayName', 'Entrenamiento');
hold on;
plot(info.ValidationLoss, 'r-', 'LineWidth', 2, 'DisplayName', 'Validación');
xlabel('Época'); ylabel('Pérdida (MSE)');
title('Evolución de la Pérdida');
legend;
grid on;
set(gca, 'YScale', 'log');

% Gráfico 2: Precisión (si está disponible)
subplot(1, 2, 2);
if isfield(info, 'TrainingAccuracy')
    plot(info.TrainingAccuracy, 'b-', 'LineWidth', 2, 'DisplayName', 'Entrenamiento');
    hold on;
    plot(info.ValidationAccuracy, 'r-', 'LineWidth', 2, 'DisplayName', 'Validación');
    xlabel('Época'); ylabel('Precisión');
    title('Evolución de la Precisión');
    legend;
    grid on;
else
    text(0.5, 0.5, 'Métrica de precisión no disponible', ...
        'HorizontalAlignment', 'center', 'FontSize', 14);
end

%% COMPARAR PREDICCIONES vs REALES (Conjunto de Prueba)
figure('Name', 'Predicciones vs Valores Reales (Prueba)', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 500]);

% Salida 1: Control Convencional
subplot(1, 2, 1);
plot(1:length(test_idx), Y_test(1, :), 'bo-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Real');
hold on;
plot(1:length(test_idx), Y_pred_test(1, :), 'rs-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Predicción');
xlabel('Muestra'); ylabel('Control (0-1)');
title('Control Iluminación Convencional');
legend;
grid on;
ylim([-0.1, 1.1]);

% Salida 2: Intensidad Solar
subplot(1, 2, 2);
plot(1:length(test_idx), Y_test(2, :), 'bo-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Real');
hold on;
plot(1:length(test_idx), Y_pred_test(2, :), 'rs-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Predicción');
xlabel('Muestra'); ylabel('Intensidad (0-1 normalizado)');
title('Intensidad Iluminación Solar');
legend;
grid on;
ylim([-0.05, 1.05]);

%% GUARDAR MODELO ENTRENADO
fprintf('\n=== GUARDANDO MODELO ===\n');
save('modelo_red_neuronal.mat', 'net', 'info', 'mse_train', 'mse_val', 'mse_test', ...
     'mae_train', 'mae_val', 'mae_test', 'train_idx', 'val_idx', 'test_idx');

fprintf('✓ Modelo guardado en: modelo_red_neuronal.mat\n');
fprintf('\n================================\n');
fprintf('Entrenamiento completado exitosamente!\n');
fprintf('================================\n');
