%% GENERADOR DE DATASET - 24 HORAS DE TRÁFICO
% Genera datos simulados de 24 horas cada 15 minutos
% Variables: hora, iluminación natural, cantidad vehículos, velocidad
% Salidas: control convencional (0-1), intensidad solar (0-100%)

clear all; close all; clc;

%% PARÁMETROS
horas_totales = 24;
minutos_intervalo = 15;
num_muestras = (horas_totales * 60) / minutos_intervalo; % 96 muestras
num_carriles = 3;
max_vehiculos_carril = 10;
max_velocidad = 100; % km/h

%% INICIALIZAR DATASET
datos = [];
hora_del_dia = [];
iluminacion_natural = [];
total_vehiculos = [];
velocidad_promedio = [];
control_convencional = [];
intensidad_solar = [];

%% GENERAR DATOS PARA CADA INTERVALO
for i = 1:num_muestras
    % Calcular hora actual
    minutos_acumulados = (i-1) * minutos_intervalo;
    hora = mod(minutos_acumulados / 60, 24);
    hora_del_dia = [hora_del_dia; hora];
    
    %% ILUMINACIÓN NATURAL (función senoidal basada en hora del día)
    % Máximo al mediodía (hora 12), mínimo en madrugada
    if hora >= 6 && hora <= 18
        % Período de luz (6:00 - 18:00)
        ilum = 50 * (sin(pi * (hora - 6) / 12) + 0.5) + randn() * 5;
    else
        % Período oscuro (18:00 - 6:00)
        ilum = 5 + randn() * 2;
    end
    ilum = max(0, ilum); % No negativo
    iluminacion_natural = [iluminacion_natural; ilum];
    
    %% TRÁFICO (vehículos y velocidad)
    % Mayor tráfico en horas pico
    if (hora >= 7 && hora <= 9) || (hora >= 17 && hora <= 19)
        % Horas pico: más vehículos, velocidad variable
        num_veh = randi([6, 10], 1, num_carriles);
        vel_prom = 40 + randn() * 15; % Congestión
    elseif (hora >= 10 && hora <= 16)
        % Horas normales
        num_veh = randi([3, 7], 1, num_carriles);
        vel_prom = 70 + randn() * 15;
    else
        % Madrugada y tardenoche: menos tráfico
        num_veh = randi([0, 3], 1, num_carriles);
        vel_prom = 80 + randn() * 10;
    end
    
    vel_prom = max(10, min(max_velocidad, vel_prom)); % Limitar velocidad
    total_vehiculos = [total_vehiculos; sum(num_veh)];
    velocidad_promedio = [velocidad_promedio; vel_prom];
    
    %% SALIDAS (Control de iluminación)
    % Control convencional: se enciende cuando hay oscuridad o congestión
    if ilum < 20
        % Oscuridad
        control_conv = 1;
    elseif ilum < 40 && total_vehiculos(end) > 5
        % Luz reducida pero hay tráfico
        control_conv = 1;
    else
        % Hay suficiente luz natural
        control_conv = 0;
    end
    control_convencional = [control_convencional; control_conv];
    
    % Intensidad solar: maximizar uso de energía solar cuando hay luz
    % Pero reducir si hay suficiente luz natural
    if ilum > 40
        % Mucha luz natural, usar energía solar
        intens_solar = 70 + randn() * 10;
    elseif ilum > 20
        % Luz moderada
        intens_solar = 40 + randn() * 15;
    else
        % Oscuridad, energía solar al máximo (si hay batería)
        intens_solar = 20 + randn() * 10;
    end
    
    intens_solar = max(0, min(100, intens_solar)); % Limitar 0-100%
    intensidad_solar = [intensidad_solar; intens_solar];
end

%% NORMALIZAR ENTRADAS (0-1) para mejor entrenamiento de la red
% Entrada 1: Hora (0-23)
entrada_hora = hora_del_dia / 24;

% Entrada 2: Iluminación natural (cd/m²)
entrada_ilum = iluminacion_natural / 100; % Escalar a rango comparable

% Entrada 3: Total de vehículos (0-30)
entrada_vehiculos = total_vehiculos / (num_carriles * max_vehiculos_carril);

% Entrada 4: Velocidad (0-100 km/h)
entrada_velocidad = velocidad_promedio / max_velocidad;

%% CREAR MATRIZ DE ENTRADA Y SALIDA
% Entrada: [hora, iluminación, vehículos, velocidad]
X = [entrada_hora, entrada_ilum, entrada_vehiculos, entrada_velocidad];

% Salida: [control_convencional, intensidad_solar]
Y = [control_convencional, intensidad_solar / 100]; % Normalizar solar a 0-1

%% MOSTRAR ESTADÍSTICAS
fprintf('\n=== ESTADÍSTICAS DEL DATASET ===\n');
fprintf('Total de muestras: %d\n', num_muestras);
fprintf('Período: 24 horas (cada %d minutos)\n', minutos_intervalo);
fprintf('Número de carriles: %d\n', num_carriles);
fprintf('\nRango de entradas:\n');
fprintf('  Hora: %.2f - %.2f (normalizado 0-1)\n', min(entrada_hora), max(entrada_hora));
fprintf('  Iluminación: %.2f - %.2f cd/m² (normalizado 0-1)\n', min(iluminacion_natural), max(iluminacion_natural));
fprintf('  Vehículos: %d - %d (normalizado 0-1)\n', min(total_vehiculos), max(total_vehiculos));
fprintf('  Velocidad: %.2f - %.2f km/h (normalizado 0-1)\n', min(velocidad_promedio), max(velocidad_promedio));
fprintf('\nRango de salidas:\n');
fprintf('  Control convencional: 0 (apagado) o 1 (encendido)\n');
fprintf('  Intensidad solar: 0 - 100%%\n');

%% VISUALIZAR DATOS
figure('Name', 'Dataset - Análisis de 24 horas', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);

% Gráfico 1: Iluminación natural vs hora
subplot(2, 3, 1);
plot(hora_del_dia, iluminacion_natural, 'b-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Iluminación (cd/m²)');
title('Iluminación Natural vs Hora');
grid on;

% Gráfico 2: Tráfico vs hora
subplot(2, 3, 2);
plot(hora_del_dia, total_vehiculos, 'r-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Total vehículos');
title('Tráfico vs Hora');
grid on;

% Gráfico 3: Velocidad vs hora
subplot(2, 3, 3);
plot(hora_del_dia, velocidad_promedio, 'g-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Velocidad (km/h)');
title('Velocidad Promedio vs Hora');
grid on;

% Gráfico 4: Control convencional
subplot(2, 3, 4);
plot(hora_del_dia, control_convencional, 'ko-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Control (0/1)');
title('Control Iluminación Convencional');
ylim([-0.1, 1.1]);
grid on;

% Gráfico 5: Intensidad solar
subplot(2, 3, 5);
plot(hora_del_dia, intensidad_solar, 'mo-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Intensidad (%)');
title('Intensidad Iluminación Solar');
ylim([0, 100]);
grid on;

% Gráfico 6: Correlación entrada-salida
subplot(2, 3, 6);
scatter(iluminacion_natural, control_convencional, 50, 'filled', 'b');
hold on;
scatter(iluminacion_natural, intensidad_solar/10, 50, 'filled', 'r');
xlabel('Iluminación (cd/m²)');
ylabel('Salida normalizada');
title('Relación Iluminación - Salidas');
legend('Control convencional', 'Intensidad solar (÷10)');
grid on;

%% GUARDAR DATASET
save('dataset_24h.mat', 'X', 'Y', 'hora_del_dia', 'iluminacion_natural', ...
     'total_vehiculos', 'velocidad_promedio', 'control_convencional', ...
     'intensidad_solar', 'num_muestras');

fprintf('\n✓ Dataset guardado en: dataset_24h.mat\n');
fprintf('✓ Dimensiones:\n');
fprintf('  X (entradas): %d x 4 (muestras x características)\n', size(X, 1));
fprintf('  Y (salidas): %d x 2 (muestras x salidas)\n', size(Y, 1));
fprintf('================================\n\n');
