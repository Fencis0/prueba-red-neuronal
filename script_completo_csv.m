%% ═══════════════════════════════════════════════════════════════════════════
%% RED NEURONAL PARA CONTROL DE ILUMINACIÓN PÚBLICA INTELIGENTE
%% Script completo: Generar CSV -> Leer CSV -> Entrenar -> Validar
%% ═══════════════════════════════════════════════════════════════════════════

clear all; close all; clc;

%% BANNER INICIAL
fprintf('\n');
fprintf('╔═════════════════════════════════════════════════════════════╗\n');
fprintf('║     RED NEURONAL PARA ILUMINACIÓN PÚBLICA INTELIGENTE       ║\n');
fprintf('║    Script Completo: CSV - Entrenamiento - Validación        ║\n');
fprintf('╚═════════════════════════════════════════════════════════════╝\n\n');

%% ═══════════════════════════════════════════════════════════════════════════
%% FASE 1: GENERAR DATASET Y GUARDAR EN CSV
%% ═══════════════════════════════════════════════════════════════════════════
fprintf('┌─────────────────────────────────────────────────────────────┐\n');
fprintf('│ FASE 1: GENERANDO DATASET Y GUARDANDO EN CSV               │\n');
fprintf('└─────────────────────────────────────────────────────────────┘\n\n');

% Parámetros
horas_totales = 24;
minutos_intervalo = 15;
num_muestras = (horas_totales * 60) / minutos_intervalo; % 96 muestras
num_carriles = 3;
max_vehiculos_carril = 10;
max_velocidad = 100; % km/h

fprintf('Parámetros:\n');
fprintf('  • Total de muestras: %d\n', num_muestras);
fprintf('  • Período: 24 horas\n');
fprintf('  • Intervalo: %d minutos\n', minutos_intervalo);
fprintf('  • Número de carriles: %d\n', num_carriles);
fprintf('  • Máximo vehículos por carril: %d\n', max_vehiculos_carril);
fprintf('  • Velocidad máxima: %d km/h\n\n', max_velocidad);

% Inicializar arrays
hora_del_dia = [];
iluminacion_natural = [];
total_vehiculos = [];
velocidad_promedio = [];
control_convencional = [];
intensidad_solar = [];

fprintf('Generando datos');

% Generar datos para cada intervalo
for i = 1:num_muestras
    if mod(i, 16) == 0, fprintf('.'); end % Mostrar progreso
    
    % Hora actual
    minutos_acumulados = (i-1) * minutos_intervalo;
    hora = mod(minutos_acumulados / 60, 24);
    hora_del_dia = [hora_del_dia; hora];
    
    %% ILUMINACIÓN NATURAL (función senoidal)
    if hora >= 6 && hora <= 18
        ilum = 50 * (sin(pi * (hora - 6) / 12) + 0.5) + randn() * 5;
    else
        ilum = 5 + randn() * 2;
    end
    ilum = max(0, ilum);
    iluminacion_natural = [iluminacion_natural; ilum];
    
    %% TRÁFICO
    if (hora >= 7 && hora <= 9) || (hora >= 17 && hora <= 19)
        num_veh = randi([6, 10], 1, num_carriles);
        vel_prom = 40 + randn() * 15;
    elseif (hora >= 10 && hora <= 16)
        num_veh = randi([3, 7], 1, num_carriles);
        vel_prom = 70 + randn() * 15;
    else
        num_veh = randi([0, 3], 1, num_carriles);
        vel_prom = 80 + randn() * 10;
    end
    
    vel_prom = max(10, min(max_velocidad, vel_prom));
    total_vehiculos = [total_vehiculos; sum(num_veh)];
    velocidad_promedio = [velocidad_promedio; vel_prom];
    
    %% SALIDAS
    if ilum < 20
        control_conv = 1;
    elseif ilum < 40 && total_vehiculos(end) > 5
        control_conv = 1;
    else
        control_conv = 0;
    end
    control_convencional = [control_convencional; control_conv];
    
    if ilum > 40
        intens_solar = 70 + randn() * 10;
    elseif ilum > 20
        intens_solar = 40 + randn() * 15;
    else
        intens_solar = 20 + randn() * 10;
    end
    intens_solar = max(0, min(100, intens_solar));
    intensidad_solar = [intensidad_solar; intens_solar];
end

fprintf('\n✓ Dataset generado exitosamente\n\n');

%% CREAR TABLA Y GUARDAR EN CSV
fprintf('Guardando dataset en CSV...\n\n');

% Crear tabla con todas las columnas
dataset_table = table(...
    hora_del_dia, ...
    iluminacion_natural, ...
    total_vehiculos, ...
    velocidad_promedio, ...
    control_convencional, ...
    intensidad_solar, ...
    'VariableNames', {'Hora', 'Iluminacion_cd_m2', 'Total_Vehiculos', ...
                      'Velocidad_km_h', 'Control_Convencional', 'Intensidad_Solar_porciento'});

% Guardar en CSV
writetable(dataset_table, 'dataset_iluminacion_24h.csv');

fprintf('✓ Dataset guardado en: dataset_iluminacion_24h.csv\n\n');

% Mostrar vista previa
fprintf('Vista previa del dataset (primeras 5 filas):\n');
disp(dataset_table(1:5, :));

fprintf('\nEstadísticas del Dataset:\n');
fprintf('  • Total de filas: %d\n', height(dataset_table));
fprintf('  • Hora: %.2f - %.2f horas\n', min(hora_del_dia), max(hora_del_dia));
fprintf('  • Iluminación: %.2f - %.2f cd/m²\n', min(iluminacion_natural), max(iluminacion_natural));
fprintf('  • Vehículos: %d - %d\n', min(total_vehiculos), max(total_vehiculos));
fprintf('  • Velocidad: %.2f - %.2f km/h\n\n', min(velocidad_promedio), max(velocidad_promedio));

%% VISUALIZAR DATOS DEL CSV
fig1 = figure('Name', 'Dataset - Análisis de 24 horas', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 800], 'Visible', 'on');

subplot(2, 3, 1);
plot(hora_del_dia, iluminacion_natural, 'b-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Iluminación (cd/m²)'); title('Iluminación Natural vs Hora'); grid on;

subplot(2, 3, 2);
plot(hora_del_dia, total_vehiculos, 'r-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Total vehículos'); title('Tráfico vs Hora'); grid on;

subplot(2, 3, 3);
plot(hora_del_dia, velocidad_promedio, 'g-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Velocidad (km/h)'); title('Velocidad Promedio vs Hora'); grid on;

subplot(2, 3, 4);
plot(hora_del_dia, control_convencional, 'ko-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Control (0/1)'); title('Control Iluminación Convencional');
ylim([-0.1, 1.1]); grid on;

subplot(2, 3, 5);
plot(hora_del_dia, intensidad_solar, 'mo-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Intensidad (%)'); title('Intensidad Iluminación Solar');
ylim([0, 100]); grid on;

subplot(2, 3, 6);
scatter(iluminacion_natural, control_convencional, 50, 'filled', 'b');
hold on;
scatter(iluminacion_natural, intensidad_solar/10, 50, 'filled', 'r');
xlabel('Iluminación (cd/m²)'); ylabel('Salida normalizada');
title('Relación Iluminación - Salidas');
legend('Control convencional', 'Intensidad solar (÷10)'); grid on;

drawnow;

%% ═══════════════════════════════════════════════════════════════════════════
%% FASE 2: LEER DATOS DEL CSV
%% ═══════════════════════════════════════════════════════════════════════════
fprintf('┌─────────────────────────────────────────────────────────────┐\n');
fprintf('│ FASE 2: LEYENDO DATOS DEL CSV                              │\n');
fprintf('└─────────────────────────────────────────────────────────────┘\n\n');

fprintf('Leyendo archivo: dataset_iluminacion_24h.csv\n');

% Leer tabla desde CSV
datos_csv = readtable('dataset_iluminacion_24h.csv');

fprintf('✓ Archivo leído exitosamente\n');
fprintf('  • Filas: %d\n', height(datos_csv));
fprintf('  • Columnas: %d\n\n', width(datos_csv));

% Extraer variables
hora = datos_csv.Hora;
ilum = datos_csv.Iluminacion_cd_m2;
veh = datos_csv.Total_Vehiculos;
vel = datos_csv.Velocidad_km_h;
control = datos_csv.Control_Convencional;
solar = datos_csv.Intensidad_Solar_porciento;

fprintf('Columnas disponibles en el CSV:\n');
for i = 1:width(datos_csv)
    fprintf('  %d. %s\n', i, datos_csv.Properties.VariableNames{i});
end
fprintf('\n');

%% NORMALIZAR ENTRADAS
entrada_hora = hora / 24;
entrada_ilum = ilum / 100;
entrada_vehiculos = veh / (num_carriles * max_vehiculos_carril);
entrada_velocidad = vel / max_velocidad;

X = [entrada_hora, entrada_ilum, entrada_vehiculos, entrada_velocidad];
Y = [control, solar / 100];

fprintf('Datos normalizados para entrenamiento:\n');
fprintf('  • X (entradas): %d x %d\n', size(X, 1), size(X, 2));
fprintf('  • Y (salidas): %d x %d\n\n', size(Y, 1), size(Y, 2));

%% ═══════════════════════════════════════════════════════════════════════════
%% FASE 3: ENTRENAR RED NEURONAL
%% ═══════════════════════════════════════════════════════════════════════════
fprintf('┌─────────────────────────────────────────────────────────────┐\n');
fprintf('│ FASE 3: ENTRENANDO RED NEURONAL                            │\n');
fprintf('└─────────────────────────────────────────────────────────────┘\n\n');

% Dividir en conjuntos
num_muestras_total = size(X, 1);
indices = randperm(num_muestras_total);

train_idx = indices(1:round(0.7*num_muestras_total));
val_idx = indices(round(0.7*num_muestras_total)+1:round(0.85*num_muestras_total));
test_idx = indices(round(0.85*num_muestras_total)+1:end);

X_train = X(train_idx, :)';
Y_train = Y(train_idx, :)';
X_val = X(val_idx, :)';
Y_val = Y(val_idx, :)';
X_test = X(test_idx, :)';
Y_test = Y(test_idx, :)';

fprintf('División del Dataset:\n');
fprintf('  • Entrenamiento: %d muestras (70%%)\n', length(train_idx));
fprintf('  • Validación: %d muestras (15%%)\n', length(val_idx));
fprintf('  • Prueba: %d muestras (15%%)\n\n', length(test_idx));

% Crear red neuronal
fprintf('Arquitectura de Red Neuronal:\n');
fprintf('  • Entrada: 4 neuronas (hora, iluminación, vehículos, velocidad)\n');
fprintf('  • Capa oculta 1: 10 neuronas (ReLU)\n');
fprintf('  • Capa oculta 2: 15 neuronas (ReLU)\n');
fprintf('  • Salida: 2 neuronas (Sigmoid)\n');
fprintf('  • Optimizador: Adam\n');
fprintf('  • Épocas: 500\n\n');

hiddenLayerSize = [10, 15];
net = fitnetwork(4, hiddenLayerSize, 2, 'trainlm');

% Configurar funciones de activación
net.hiddenConnections(1).transferFcn = 'relu';
net.hiddenConnections(2).transferFcn = 'relu';
net.outputConnections.transferFcn = 'sigmoid';

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

fprintf('Iniciando entrenamiento...\n');
tic;
[net, info] = trainNetwork(X_train, Y_train, net, options);
tiempo_entrenamiento = toc;

fprintf('\n✓ Entrenamiento completado en %.2f segundos\n\n', tiempo_entrenamiento);

%% ═══���═══════════════════════════════════════════════════════════════════════
%% FASE 4: VALIDAR MODELO
%% ═══════════════════════════════════════════════════════════════════════════
fprintf('┌─────────────────────────────────────────────────────────────┐\n');
fprintf('│ FASE 4: VALIDANDO MODELO                                   │\n');
fprintf('└─────────────────────────────────────────────────────────────┘\n\n');

% Predicciones
Y_pred_train = predict(net, X_train);
Y_pred_val = predict(net, X_val);
Y_pred_test = predict(net, X_test);

% Errores globales
mse_train = mean((Y_pred_train - Y_train).^2, 'all');
mse_val = mean((Y_pred_val - Y_val).^2, 'all');
mse_test = mean((Y_pred_test - Y_test).^2, 'all');

mae_train = mean(abs(Y_pred_train - Y_train), 'all');
mae_val = mean(abs(Y_pred_val - Y_val), 'all');
mae_test = mean(abs(Y_pred_test - Y_test), 'all');

fprintf('Error Cuadrático Medio (MSE):\n');
fprintf('  • Entrenamiento: %.6f\n', mse_train);
fprintf('  • Validación: %.6f\n', mse_val);
fprintf('  • Prueba: %.6f\n\n', mse_test);

fprintf('Error Absoluto Medio (MAE):\n');
fprintf('  • Entrenamiento: %.6f\n', mae_train);
fprintf('  • Validación: %.6f\n', mae_val);
fprintf('  • Prueba: %.6f\n\n', mae_test);

%% ANÁLISIS POR SALIDA
% Salida 1: Control Convencional
error_conv = Y_pred_test(1, :) - Y_test(1, :);
mse_conv = mean(error_conv.^2);
mae_conv = mean(abs(error_conv));
rmse_conv = sqrt(mse_conv);

fprintf('═════ SALIDA 1: CONTROL ILUMINACIÓN CONVENCIONAL ═════\n');
fprintf('  MSE: %.6f\n', mse_conv);
fprintf('  MAE: %.6f\n', mae_conv);
fprintf('  RMSE: %.6f\n\n', rmse_conv);

% Salida 2: Intensidad Solar
error_solar = Y_pred_test(2, :) - Y_test(2, :);
mse_solar = mean(error_solar.^2);
mae_solar = mean(abs(error_solar));
rmse_solar = sqrt(mse_solar);

fprintf('═════ SALIDA 2: INTENSIDAD ILUMINACIÓN SOLAR ═════\n');
fprintf('  MSE: %.6f\n', mse_solar);
fprintf('  MAE: %.6f\n', mae_solar);
fprintf('  RMSE: %.6f\n\n', rmse_solar);

%% MATRIZ DE CONFUSIÓN
Y_conv_real = round(Y_test(1, :));
Y_conv_pred = round(Y_pred_test(1, :));

TP = sum((Y_conv_pred == 1) & (Y_conv_real == 1));
TN = sum((Y_conv_pred == 0) & (Y_conv_real == 0));
FP = sum((Y_conv_pred == 1) & (Y_conv_real == 0));
FN = sum((Y_conv_pred == 0) & (Y_conv_real == 1));

accuracy = (TP + TN) / (TP + TN + FP + FN);
precision = TP / (TP + FP + eps);
recall = TP / (TP + FN + eps);
f1 = 2 * (precision * recall) / (precision + recall + eps);

fprintf('═════ MATRIZ DE CONFUSIÓN (Control Convencional) ═════\n');
fprintf('              Predicción\n');
fprintf('             Negativo  Positivo\n');
fprintf('Real Negativo  %3d      %3d\n', TN, FP);
fprintf('     Positivo  %3d      %3d\n\n', FN, TP);

fprintf('Métricas de Clasificación:\n');
fprintf('  • Accuracy: %.4f (%.2f%%)\n', accuracy, accuracy*100);
fprintf('  • Precision: %.4f\n', precision);
fprintf('  • Recall/Sensitivity: %.4f\n', recall);
fprintf('  • F1-Score: %.4f\n\n', f1);

%% CORRELACIÓN
corr_conv = corrcoef(Y_test(1, :), Y_pred_test(1, :));
corr_solar = corrcoef(Y_test(2, :), Y_pred_test(2, :));

fprintf('Correlación de Pearson:\n');
fprintf('  • Control Convencional: %.4f\n', corr_conv(1, 2));
fprintf('  • Intensidad Solar: %.4f\n\n', corr_solar(1, 2));

%% ═══════════════════════════════════════════════════════════════════════════
%% VISUALIZACIONES FINALES
%% ═══════════════════════════════════════════════════════════════════════════

% Figura 2: Resultados de Entrenamiento
fig2 = figure('Name', 'Resultados de Entrenamiento', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 500]);

subplot(1, 2, 1);
plot(info.TrainingLoss, 'b-', 'LineWidth', 2, 'DisplayName', 'Entrenamiento');
hold on;
plot(info.ValidationLoss, 'r-', 'LineWidth', 2, 'DisplayName', 'Validación');
xlabel('Época'); ylabel('Pérdida (MSE)'); title('Evolución de la Pérdida'); legend; grid on;
set(gca, 'YScale', 'log');

subplot(1, 2, 2);
plot(1:length(test_idx), Y_test(1, :), 'bo-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Real');
hold on;
plot(1:length(test_idx), Y_pred_test(1, :), 'rs-', 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Predicción');
xlabel('Muestra'); ylabel('Control (0-1)'); title('Control Convencional - Predicciones');
legend; grid on; ylim([-0.1, 1.1]);

drawnow;

% Figura 3: Análisis Detallado
fig3 = figure('Name', 'Análisis Detallado de Validación', 'NumberTitle', 'off', ...
    'Position', [50, 50, 1400, 900]);

% Distribución de errores - Control
subplot(3, 3, 1);
histogram(error_conv, 15, 'FaceColor', 'b', 'EdgeColor', 'black');
xlabel('Error'); ylabel('Frecuencia'); title('Distribución de errores - Control'); grid on;

% Distribución de errores - Solar
subplot(3, 3, 2);
histogram(error_solar, 15, 'FaceColor', 'r', 'EdgeColor', 'black');
xlabel('Error'); ylabel('Frecuencia'); title('Distribución de errores - Solar'); grid on;

% Q-Q Plot
subplot(3, 3, 3);
qqplot(error_conv);
title('Q-Q Plot - Control Convencional'); grid on;

% Scatter Real vs Predicho - Control
subplot(3, 3, 4);
scatter(Y_test(1, :), Y_pred_test(1, :), 50, 'filled', 'b');
hold on; plot([0, 1], [0, 1], 'r--', 'LineWidth', 2);
xlabel('Valor Real'); ylabel('Valor Predicho');
title(sprintf('Control Convencional (r=%.4f)', corr_conv(1, 2)));
grid on; xlim([-0.05, 1.05]); ylim([-0.05, 1.05]);

% Scatter Real vs Predicho - Solar
subplot(3, 3, 5);
scatter(Y_test(2, :), Y_pred_test(2, :), 50, 'filled', 'r');
hold on; plot([0, 1], [0, 1], 'b--', 'LineWidth', 2);
xlabel('Valor Real'); ylabel('Valor Predicho');
title(sprintf('Intensidad Solar (r=%.4f)', corr_solar(1, 2)));
grid on; xlim([-0.05, 1.05]); ylim([-0.05, 1.05]);

% Error temporal - Control
subplot(3, 3, 6);
plot(1:length(test_idx), error_conv, 'b-', 'LineWidth', 1.5);
hold on; yline(0, 'r--', 'LineWidth', 2);
xlabel('Muestra'); ylabel('Error'); title('Error temporal - Control'); grid on;

% Error temporal - Solar
subplot(3, 3, 7);
plot(1:length(test_idx), error_solar, 'r-', 'LineWidth', 1.5);
hold on; yline(0, 'b--', 'LineWidth', 2);
xlabel('Muestra'); ylabel('Error'); title('Error temporal - Solar'); grid on;

% Residuos - Control
subplot(3, 3, 8);
scatter(Y_pred_test(1, :), error_conv, 50, 'filled', 'b');
hold on; yline(0, 'r--', 'LineWidth', 2);
xlabel('Valor Predicho'); ylabel('Residuo'); title('Residuos - Control'); grid on;

% Residuos - Solar
subplot(3, 3, 9);
scatter(Y_pred_test(2, :), error_solar, 50, 'filled', 'r');
hold on; yline(0, 'b--', 'LineWidth', 2);
xlabel('Valor Predicho'); ylabel('Residuo'); title('Residuos - Solar'); grid on;

drawnow;

% Figura 4: Predicciones completas vs reales
fig4 = figure('Name', 'Predicciones Completas', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 400]);

subplot(1, 2, 1);
plot(1:length(test_idx), Y_test(1, :), 'b-', 'LineWidth', 2, 'DisplayName', 'Real');
hold on;
plot(1:length(test_idx), Y_pred_test(1, :), 'r--', 'LineWidth', 2, 'DisplayName', 'Predicción');
xlabel('Muestra'); ylabel('Intensidad (0-100%)');
title('Control Iluminación Convencional'); legend; grid on;

subplot(1, 2, 2);
plot(1:length(test_idx), Y_test(2, :)*100, 'b-', 'LineWidth', 2, 'DisplayName', 'Real');
hold on;
plot(1:length(test_idx), Y_pred_test(2, :)*100, 'r--', 'LineWidth', 2, 'DisplayName', 'Predicción');
xlabel('Muestra'); ylabel('Intensidad (0-100%)');
title('Intensidad Iluminación Solar'); legend; grid on;

drawnow;

%% ═══════════════════════════════════════════════════════════════════════════
%% RESUMEN FINAL Y GUARDAR RESULTADOS
%% ═══════════════════════════════════════════════════════════════════════════
fprintf('\n╔═════════════════════════════════════════════════════════════╗\n');
fprintf('║                 RESUMEN FINAL DE RESULTADOS               ║\n');
fprintf('╠═════════════════════════════════════════════════════════════╣\n');
fprintf('║ SALIDA 1: CONTROL ILUMINACIÓN CONVENCIONAL                ║\n');
fprintf('╟─────────────────────────────────────────────────────────────╢\n');
fprintf('║ • MSE (Prueba): %.6f                                ║\n', mse_conv);
fprintf('║ • MAE (Prueba): %.6f                                ║\n', mae_conv);
fprintf('║ • RMSE (Prueba): %.6f                               ║\n', rmse_conv);
fprintf('║ • Correlación: %.4f                                    ║\n', corr_conv(1, 2));
fprintf('║ • Accuracy: %.4f (%.2f%%)                             ║\n', accuracy, accuracy*100);
fprintf('║ • F1-Score: %.4f                                      ║\n', f1);
fprintf('╠═════════════════════════════════════════════════════════════╣\n');
fprintf('║ SALIDA 2: INTENSIDAD ILUMINACIÓN SOLAR                    ║\n');
fprintf('╟─────────────────────────────────────────────────────────────╢\n');
fprintf('║ • MSE (Prueba): %.6f                                ║\n', mse_solar);
fprintf('║ • MAE (Prueba): %.6f                                ║\n', mae_solar);
fprintf('║ • RMSE (Prueba): %.6f                               ║\n', rmse_solar);
fprintf('║ • Correlación: %.4f                                    ║\n', corr_solar(1, 2));
fprintf('╠═════════════════════════════════════════════════════════════╣\n');
fprintf('║ TIEMPO DE EJECUCIÓN                                       ║\n');
fprintf('╟─────────────────────────────────────────────────────────────╢\n');
fprintf('║ • Tiempo de entrenamiento: %.2f segundos                 ║\n', tiempo_entrenamiento);
fprintf('╠═════════════════════════════════════════════════════════════╣\n');
fprintf('║ ARCHIVOS GENERADOS                                        ║\n');
fprintf('╟─────────────────────────────────────────────────────────────╢\n');
fprintf('║ • dataset_iluminacion_24h.csv                             ║\n');
fprintf('║ • 4 figuras con análisis detallados                       ║\n');
fprintf('╚═════════════════════════════════════════════════════════════╝\n\n');

fprintf('✓ ¡PROCESO COMPLETADO EXITOSAMENTE!\n');
fprintf('✓ Se han generado 4 figuras con análisis detallados\n');
fprintf('✓ El modelo está listo para usar\n');
fprintf('✓ Dataset guardado en CSV para referencia\n\n');

%% OPCIÓN: Guardar modelo para uso futuro
save_option = input('¿Deseas guardar el modelo para uso futuro? (s/n): ', 's');
if strcmpi(save_option, 's') || strcmpi(save_option, 'si')
    save('modelo_iluminacion.mat', 'net', 'X', 'Y', 'info', 'mse_conv', 'mae_conv', ...
         'mse_solar', 'mae_solar', 'accuracy', 'f1', 'corr_conv', 'corr_solar');
    fprintf('✓ Modelo guardado como: modelo_iluminacion.mat\n\n');
end

fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('Fin del programa\n');
fprintf('═══════════════════════════════════════════════════════════════\n\n');
