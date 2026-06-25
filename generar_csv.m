%% ═══════════════════════════════════════════════════════════════════════════
%% GENERADOR DE DATASET EN CSV
%% Script auxiliar: Solo genera el archivo CSV sin entrenar
%% ═══════════════════════════════════════════════════════════════════════════

clear all; close all; clc;

fprintf('\n');
fprintf('╔═════════════════════════════════════════════════════════════╗\n');
fprintf('║          GENERADOR DE DATASET EN CSV                       ║\n');
fprintf('║     24 horas de iluminación pública simulada                ║\n');
fprintf('╚═════════════════════════════════════════════════════════════╝\n\n');

%% PARÁMETROS
horas_totales = 24;
minutos_intervalo = 15;
num_muestras = (horas_totales * 60) / minutos_intervalo;
num_carriles = 3;
max_vehiculos_carril = 10;
max_velocidad = 100;

fprintf('Configuración:\n');
fprintf('  • Total de muestras: %d\n', num_muestras);
fprintf('  • Período: 24 horas\n');
fprintf('  • Intervalo: %d minutos\n', minutos_intervalo);
fprintf('  • Número de carriles: %d\n', num_carriles);
fprintf('  • Máximo vehículos: %d por carril\n', max_vehiculos_carril);
fprintf('  • Velocidad máxima: %d km/h\n\n', max_velocidad);

%% GENERAR DATOS
hora_del_dia = [];
iluminacion_natural = [];
total_vehiculos = [];
velocidad_promedio = [];
control_convencional = [];
intensidad_solar = [];

fprintf('Generando datos');

for i = 1:num_muestras
    if mod(i, 16) == 0, fprintf('.'); end
    
    minutos_acumulados = (i-1) * minutos_intervalo;
    hora = mod(minutos_acumulados / 60, 24);
    hora_del_dia = [hora_del_dia; hora];
    
    %% ILUMINACIÓN NATURAL
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

%% CREAR Y GUARDAR CSV
fprintf('Creando tabla y guardando en CSV...\n\n');

dataset_table = table(...
    hora_del_dia, ...
    iluminacion_natural, ...
    total_vehiculos, ...
    velocidad_promedio, ...
    control_convencional, ...
    intensidad_solar, ...
    'VariableNames', {'Hora', 'Iluminacion_cd_m2', 'Total_Vehiculos', ...
                      'Velocidad_km_h', 'Control_Convencional', 'Intensidad_Solar_porciento'});

writetable(dataset_table, 'dataset_iluminacion_24h.csv');

fprintf('✓ CSV guardado: dataset_iluminacion_24h.csv\n\n');

%% MOSTRAR INFORMACIÓN
fprintf('═════════════════════════════════════════════════════════════\n');
fprintf('INFORMACIÓN DEL DATASET\n');
fprintf('═════════════════════════════════════════════════════════════\n\n');

fprintf('Estructura del CSV:\n');
fprintf('  Columna 1: Hora (0-24 horas)\n');
fprintf('  Columna 2: Iluminacion_cd_m2 (candelas/m²)\n');
fprintf('  Columna 3: Total_Vehiculos (0-30)\n');
fprintf('  Columna 4: Velocidad_km_h (10-100)\n');
fprintf('  Columna 5: Control_Convencional (0 o 1)\n');
fprintf('  Columna 6: Intensidad_Solar_porciento (0-100)\n\n');

fprintf('Estadísticas:\n');
fprintf('  • Total de filas: %d\n', height(dataset_table));
fprintf('  • Hora: %.2f - %.2f horas\n', min(hora_del_dia), max(hora_del_dia));
fprintf('  • Iluminación: %.2f - %.2f cd/m²\n', min(iluminacion_natural), max(iluminacion_natural));
fprintf('  • Vehículos: %d - %d\n', min(total_vehiculos), max(total_vehiculos));
fprintf('  • Velocidad: %.2f - %.2f km/h\n', min(velocidad_promedio), max(velocidad_promedio));
fprintf('  • Control convencional: %d encendidos, %d apagados\n', ...
        sum(control_convencional), num_muestras - sum(control_convencional));
fprintf('  • Intensidad solar: %.2f - %.2f %%\n\n', min(intensidad_solar), max(intensidad_solar));

%% MOSTRAR VISTA PREVIA
fprintf('Vista previa (primeras 10 filas del CSV):\n');
fprintf('─────────────────────────────────────────────────────────────\n');
disp(dataset_table(1:10, :));

%% CREAR VISUALIZACIÓN
fig = figure('Name', 'Dataset de 24 horas', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 800]);

subplot(2, 3, 1);
plot(hora_del_dia, iluminacion_natural, 'b-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Iluminación (cd/m²)');
title('Iluminación Natural'); grid on;

subplot(2, 3, 2);
plot(hora_del_dia, total_vehiculos, 'r-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Vehículos');
title('Cantidad de Vehículos'); grid on;

subplot(2, 3, 3);
plot(hora_del_dia, velocidad_promedio, 'g-', 'LineWidth', 2);
xlabel('Hora del día'); ylabel('Velocidad (km/h)');
title('Velocidad Promedio'); grid on;

subplot(2, 3, 4);
plot(hora_del_dia, control_convencional, 'ko-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Estado (0/1)');
title('Control Iluminación Convencional');
ylim([-0.1, 1.1]); grid on;

subplot(2, 3, 5);
plot(hora_del_dia, intensidad_solar, 'mo-', 'LineWidth', 2, 'MarkerSize', 3);
xlabel('Hora del día'); ylabel('Intensidad (%)');
title('Intensidad Iluminación Solar');
ylim([0, 100]); grid on;

subplot(2, 3, 6);
scatter(iluminacion_natural, control_convencional, 50, 'b', 'filled', 'DisplayName', 'Control Conv.');
hold on;
scatter(iluminacion_natural, intensidad_solar/10, 50, 'r', 'filled', 'DisplayName', 'Intensidad Solar (÷10)');
xlabel('Iluminación (cd/m²)');
ylabel('Salida normalizada');
title('Relación Entrada-Salida');
legend; grid on;

fprintf('\n═════════════════════════════════════════════════════════════\n');
fprintf('✓ PROCESO COMPLETADO EXITOSAMENTE\n');
fprintf('═════════════════════════════════════════════════════════════\n\n');

fprintf('El archivo "dataset_iluminacion_24h.csv" está listo para:\n');
fprintf('  1. Usar en script_completo_csv.m\n');
fprintf('  2. Importar en Excel, Python, u otro programa\n');
fprintf('  3. Editar manualmente si necesitas datos específicos\n\n');

fprintf('Para entrenar la red neuronal, ejecuta:\n');
fprintf('  >>> script_completo_csv\n\n');
