%% VALIDACIÓN Y EVALUACIÓN DEL MODELO
% Analiza en detalle el rendimiento del modelo entrenado

clear all; close all; clc;

%% CARGAR MODELO Y DATASET
fprintf('Cargando modelo y dataset...\n');
load('modelo_red_neuronal.mat');
load('dataset_24h.mat', 'X', 'Y');

net_trained = net;

%% OBTENER CONJUNTOS DE PRUEBA
X_test = X(test_idx, :)';
Y_test = Y(test_idx, :)';

%% REALIZAR PREDICCIONES
Y_pred = predict(net_trained, X_test);

%% ANÁLISIS DE ERRORES POR SALIDA
fprintf('\n=== ANÁLISIS DE ERRORES POR SALIDA ===\n');

% Salida 1: Control Convencional
error_conv = Y_pred(1, :) - Y_test(1, :);
mse_conv = mean(error_conv.^2);
mae_conv = mean(abs(error_conv));
rmse_conv = sqrt(mse_conv);

fprintf('\nSalida 1 - Control Iluminación Convencional:\n');
fprintf('  MSE: %.6f\n', mse_conv);
fprintf('  MAE: %.6f\n', mae_conv);
fprintf('  RMSE: %.6f\n', rmse_conv);
fprintf('  Error mín: %.6f\n', min(error_conv));
fprintf('  Error máx: %.6f\n', max(error_conv));
fprintf('  Std error: %.6f\n', std(error_conv));

% Salida 2: Intensidad Solar
error_solar = Y_pred(2, :) - Y_test(2, :);
mse_solar = mean(error_solar.^2);
mae_solar = mean(abs(error_solar));
rmse_solar = sqrt(mse_solar);

fprintf('\nSalida 2 - Intensidad Iluminación Solar:\n');
fprintf('  MSE: %.6f\n', mse_solar);
fprintf('  MAE: %.6f\n', mae_solar);
fprintf('  RMSE: %.6f\n', rmse_solar);
fprintf('  Error mín: %.6f\n', min(error_solar));
fprintf('  Error máx: %.6f\n', max(error_solar));
fprintf('  Std error: %.6f\n', std(error_solar));

%% MATRIZ DE CONFUSIÓN PARA CONTROL CONVENCIONAL (Clasificación binaria)
fprintf('\n=== MATRIZ DE CONFUSIÓN (Control Convencional) ===\n');

% Umbral de decisión: 0.5
Y_conv_real = round(Y_test(1, :));
Y_conv_pred = round(Y_pred(1, :));

TP = sum((Y_conv_pred == 1) & (Y_conv_real == 1));
TN = sum((Y_conv_pred == 0) & (Y_conv_real == 0));
FP = sum((Y_conv_pred == 1) & (Y_conv_real == 0));
FN = sum((Y_conv_pred == 0) & (Y_conv_real == 1));

accuraccy = (TP + TN) / (TP + TN + FP + FN);
precision = TP / (TP + FP + eps);
recall = TP / (TP + FN + eps);
f1 = 2 * (precision * recall) / (precision + recall + eps);

fprintf('Matriz de Confusión:\n');
fprintf('              Predicho\n');
fprintf('             Negativo  Positivo\n');
fprintf('Real Negativo  %3d      %3d\n', TN, FP);
fprintf('     Positivo  %3d      %3d\n\n', FN, TP);

fprintf('Métricas:\n');
fprintf('  Precisión: %.4f\n', accuraccy);
fprintf('  Sensitivity (Recall): %.4f\n', recall);
fprintf('  Specificity: %.4f\n', TN/(TN+FP+eps));
fprintf('  Precision: %.4f\n', precision);
fprintf('  F1-Score: %.4f\n', f1);

%% ANÁLISIS DE CORRELACIÓN
fprintf('\n=== ANÁLISIS DE CORRELACIÓN ===\n');

corr_conv = corrcoef(Y_test(1, :), Y_pred(1, :));
corr_solar = corrcoef(Y_test(2, :), Y_pred(2, :));

fprintf('Correlación de Pearson:\n');
fprintf('  Control Convencional: %.4f\n', corr_conv(1, 2));
fprintf('  Intensidad Solar: %.4f\n', corr_solar(1, 2));

%% VISUALIZACIONES DETALLADAS
figure('Name', 'Análisis Detallado de Validación', 'NumberTitle', 'off', 'Position', [50, 50, 1400, 900]);

% Gráfico 1: Distribución de errores - Control Convencional
subplot(3, 3, 1);
histogram(error_conv, 15, 'FaceColor', 'b', 'EdgeColor', 'black');
xlabel('Error'); ylabel('Frecuencia');
title('Distribución de errores - Control Conv.');
grid on;

% Gráfico 2: Distribución de errores - Intensidad Solar
subplot(3, 3, 2);
histogram(error_solar, 15, 'FaceColor', 'r', 'EdgeColor', 'black');
xlabel('Error'); ylabel('Frecuencia');
title('Distribución de errores - Intensidad Solar');
grid on;

% Gráfico 3: Q-Q Plot (Normalidad)
subplot(3, 3, 3);
qqplot(error_conv);
title('Q-Q Plot - Control Convencional');
grid on;

% Gráfico 4: Scatter Real vs Predicho - Control
subplot(3, 3, 4);
scatter(Y_test(1, :), Y_pred(1, :), 50, 'filled', 'b');
hold on;
plot([0, 1], [0, 1], 'r--', 'LineWidth', 2);
xlabel('Valor Real'); ylabel('Valor Predicho');
title(sprintf('Control Convencional (r=%.4f)', corr_conv(1, 2)));
grid on;
xlim([-0.05, 1.05]); ylim([-0.05, 1.05]);

% Gráfico 5: Scatter Real vs Predicho - Solar
subplot(3, 3, 5);
scatter(Y_test(2, :), Y_pred(2, :), 50, 'filled', 'r');
hold on;
plot([0, 1], [0, 1], 'b--', 'LineWidth', 2);
xlabel('Valor Real'); ylabel('Valor Predicho');
title(sprintf('Intensidad Solar (r=%.4f)', corr_solar(1, 2)));
grid on;
xlim([-0.05, 1.05]); ylim([-0.05, 1.05]);

% Gráfico 6: Error vs Índice de muestra - Control
subplot(3, 3, 6);
plot(1:length(test_idx), error_conv, 'b-', 'LineWidth', 1.5);
hold on;
yline(0, 'r--', 'LineWidth', 2);
xlabel('Muestra'); ylabel('Error');
title('Error temporal - Control Convencional');
grid on;

% Gráfico 7: Error vs Índice de muestra - Solar
subplot(3, 3, 7);
plot(1:length(test_idx), error_solar, 'r-', 'LineWidth', 1.5);
hold on;
yline(0, 'b--', 'LineWidth', 2);
xlabel('Muestra'); ylabel('Error');
title('Error temporal - Intensidad Solar');
grid on;

% Gráfico 8: Residuos vs Predicción - Control
subplot(3, 3, 8);
scatter(Y_pred(1, :), error_conv, 50, 'filled', 'b');
hold on;
yline(0, 'r--', 'LineWidth', 2);
xlabel('Valor Predicho'); ylabel('Residuo');
title('Residuos vs Predicción - Control');
grid on;

% Gráfico 9: Residuos vs Predicción - Solar
subplot(3, 3, 9);
scatter(Y_pred(2, :), error_solar, 50, 'filled', 'r');
hold on;
yline(0, 'b--', 'LineWidth', 2);
xlabel('Valor Predicho'); ylabel('Residuo');
title('Residuos vs Predicción - Solar');
grid on;

%% TABLA DE RESUMEN
fprintf('\n=== RESUMEN DE MÉTRICAS ===\n');
fprintf('╔════════════════════════════════════════════════════╗\n');
fprintf('║        SALIDA 1: CONTROL CONVENCIONAL             ║\n');
fprintf('╠════════════════════════════════════════════════════╣\n');
fprintf('║ MSE              : %.6f                     ║\n', mse_conv);
fprintf('║ MAE              : %.6f                     ║\n', mae_conv);
fprintf('║ RMSE             : %.6f                     ║\n', rmse_conv);
fprintf('║ Correlación (r)  : %.4f                        ║\n', corr_conv(1, 2));
fprintf('║ Accuracy         : %.4f (%.2f%%)                  ║\n', accuraccy, accuraccy*100);
fprintf('║ F1-Score         : %.4f                        ║\n', f1);
fprintf('╚════════════════════════════════════════════════════╝\n');

fprintf('\n╔════════════════════════════════════════════════════╗\n');
fprintf('║      SALIDA 2: INTENSIDAD ILUMINACIÓN SOLAR       ║\n');
fprintf('╠════════════════════════════════════════════════════╣\n');
fprintf('║ MSE              : %.6f                     ║\n', mse_solar);
fprintf('║ MAE              : %.6f                     ║\n', mae_solar);
fprintf('║ RMSE             : %.6f                     ║\n', rmse_solar);
fprintf('║ Correlación (r)  : %.4f                        ║\n', corr_solar(1, 2));
fprintf('╚════════════════════════════════════════════════════╝\n');

%% GUARDAR RESULTADOS
fprintf('\n✓ Análisis completado\n');
save('resultados_validacion.mat', 'mse_conv', 'mae_conv', 'rmse_conv', ...
     'mse_solar', 'mae_solar', 'rmse_solar', 'corr_conv', 'corr_solar', ...
     'error_conv', 'error_solar', 'Y_pred', 'Y_test');
