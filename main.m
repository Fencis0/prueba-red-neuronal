%% SCRIPT PRINCIPAL - RED NEURONAL PARA ILUMINACIÓN PÚBLICA
% Ejecutar este archivo para:
% 1. Generar dataset de 24 horas
% 2. Entrenar la red neuronal
% 3. Validar y visualizar resultados

clear all; close all; clc;

%% MENÚ PRINCIPAL
fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
fprintf('║   RED NEURONAL PARA CONTROL DE ILUMINACIÓN PÚBLICA        ║\n');
fprintf('║           Proyecto de IA y Eficiencia Energética          ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

fprintf('Selecciona qué deseas hacer:\n');
fprintf('  1. Generar dataset (24 horas)\n');
fprintf('  2. Entrenar red neuronal\n');
fprintf('  3. Validar modelo\n');
fprintf('  4. Ejecutar todo (1 -> 2 -> 3)\n');
fprintf('  5. Salir\n\n');

opcion = input('Ingresa tu opción [1-5]: ');

switch opcion
    case 1
        %% GENERAR DATASET
        fprintf('\n>>> Generando dataset...\n');
        cd data
        generar_dataset
        cd ..
        
    case 2
        %% ENTRENAR RED NEURONAL
        fprintf('\n>>> Entrenando red neuronal...\n');
        if ~isfile('data/dataset_24h.mat')
            fprintf('⚠ Error: No se encontró dataset_24h.mat\n');
            fprintf('Por favor ejecuta la opción 1 primero.\n');
            return;
        end
        cd data
        % Copiar script a carpeta data temporalmente si es necesario
        cd ..
        cd src
        red_neuronal
        cd ..
        
    case 3
        %% VALIDAR MODELO
        fprintf('\n>>> Validando modelo...\n');
        if ~isfile('data/dataset_24h.mat')
            fprintf('⚠ Error: No se encontró dataset_24h.mat\n');
            return;
        end
        if ~isfile('data/modelo_red_neuronal.mat')
            fprintf('⚠ Error: No se encontró modelo_red_neuronal.mat\n');
            fprintf('Por favor ejecuta la opción 2 primero.\n');
            return;
        end
        cd src
        validar_modelo
        cd ..
        
    case 4
        %% EJECUTAR TODO
        fprintf('\n>>> Iniciando proceso completo...\n\n');
        
        % Paso 1: Generar dataset
        fprintf('PASO 1: Generando dataset...\n');
        fprintf('════════════════════════════════\n');
        cd data
        generar_dataset
        cd ..
        
        pause(2);
        
        % Paso 2: Entrenar red
        fprintf('\n\nPASO 2: Entrenando red neuronal...\n');
        fprintf('════════════════════════════════\n');
        cd src
        red_neuronal
        cd ..
        
        pause(2);
        
        % Paso 3: Validar
        fprintf('\n\nPASO 3: Validando modelo...\n');
        fprintf('════════════════════════════════\n');
        cd src
        validar_modelo
        cd ..
        
        fprintf('\n════════════════════════════════\n');
        fprintf('✓ PROCESO COMPLETADO EXITOSAMENTE\n');
        fprintf('════════════════════════════════\n');
        
    case 5
        fprintf('\n¡Hasta luego!\n');
        return;
        
    otherwise
        fprintf('\n⚠ Opción no válida. Por favor intenta de nuevo.\n');
end

fprintf('\n✓ Operación finalizada\n');
fprintf('Los resultados se han guardado en sus respectivas carpetas.\n\n');
