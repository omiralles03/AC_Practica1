#!/bin/bash

# Obtener el directorio del script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ruta al simulador
SIMULATOR="$BASE_DIR/simplesim-3.0_ecx/sim-outorder"
SIMULATOR2="$BASE_DIR/simplesim-3.0_ecx/sim-bpred"

# Parámetros comunes
FASTFWD=100000000
MAX_INST=100000000
WIDTH=32
CYCLES=300
CONSECUTIVE=2

# Archivo de salida consolidado
CONSOLIDATED_OUTPUT="$BASE_DIR/Results/ALL_Results.txt"

# Obtener el tiempo de inicio
start_time=$(date +%s)

# Benchmarks y sus comandos específicos
declare -A BENCHMARKS
BENCHMARKS["applu"]="< applu.in > applu.out 2> applu.err"
BENCHMARKS["art"]="-scanfile c756hel.in -trainfile1 a10.img -trainfile2 hc.img -stride 2 -startx 110 -starty 200 -endx 160 -endy 240 -objects 10 > ref.1.out 2> ref.1.err
-scanfile c756hel.in -trainfile1 a10.img -trainfile2 hc.img -stride 2 -startx 470 -starty 140 -endx 520 -endy 180 -objects 10 > ref.2.out 2> ref.2.err"
BENCHMARKS["gzip"]="input.source 60 > input.source.out 2> input.source.err
input.log 60 > input.log.out 2> input.log.err
input.graphic 60 > input.graphic.out 2> input.graphic.err
input.graphic 60 > input.graphic.out 2> input.graphic.err
input.random 60 > input.random.out 2> input.random.err
input.program 60 > input.program.out 2> input.program.err"
BENCHMARKS["mesa"]="-frames 1000 -meshfile mesa.in -ppmfile mesa.ppm"
BENCHMARKS["twolf"]="ref > ref.stdout 2> ref.err"

# Configuraciones para cada predictor dinámico
declare -A CONFIGURATIONS
CONFIGURATIONS["bimodal"]="8 32 128 512 2048"
CONFIGURATIONS["2lev_gshare"]="1 8 32 128 512 2048"
CONFIGURATIONS["2lev_gag"]="1 8 32 128 512 2048"
CONFIGURATIONS["2lev_pag"]="4-4 8-16 16-64 32-256 64-1024 32-2048"


timer ()
{
    
# Obtener el tiempo de finalización
end_time=$(date +%s)

# Calcular la diferencia de tiempo
execution_time=$((end_time - start_time))

# Convertir el tiempo a minutos y segundos
minutes=$((execution_time / 60))
seconds=$((execution_time % 60))

# Imprimir el tiempo de ejecución en formato min:seg
echo "Tiempo total de ejecución: $minutes min $seconds seg"
}

# Función para extraer IPC y dir_rate y agregarlo al archivo consolidado
extract_results() {
    local output_file=$1
    local bench=$2
    local predictor=$3
    local config=$4

    # Extraer el IPC del archivo de salida de la simulación
    ipc=$(grep -i "sim_IPC" "$output_file")

    # Definir prefijo del predictor según el tipo
    case $predictor in
        "bimodal") predictor_prefix="bpred_bimod";;
        "2lev_gshare" | "2lev_gag" | "2lev_pag") predictor_prefix="bpred_2lev";;
        "nottaken") predictor_prefix="bpred_nottaken";;
        "taken") predictor_prefix="bpred_taken";;
        "perfect") predictor_prefix="";;  # Perfect no tiene dir_rate porque es 100%
    esac

    # Extraer dir_rate si el predictor no es perfecto
    if [ "$predictor" != "perfect" ]; then
        dir_rate=$(grep -i "${predictor_prefix}.bpred_dir_rate" "$output_file")
    else
        dir_rate="bpred_dir_rate: 1.0000 (Perfect Predictor)"
    fi

    # Agregar los resultados al archivo consolidado con información del benchmark, predictor y configuración
    echo -e "\nBenchmark: $bench, Predictor: $predictor, Config: $config" >> "$CONSOLIDATED_OUTPUT"
    echo "$ipc" >> "$CONSOLIDATED_OUTPUT"
    echo "$dir_rate" >> "$CONSOLIDATED_OUTPUT"
}

# Función para ejecutar una simulación de (T, NT y PERFECT)
execute_simulation_static() {
    local BENCH=$1
    local EXE="$BASE_DIR/Benchmarks/$BENCH/exe/$BENCH.exe"
    local COMMAND="${BENCHMARKS[$BENCH]}"

    # Cambiar al directorio de referencia del benchmark
    local BENCH_DIR="$BASE_DIR/Benchmarks/$BENCH/data/ref"
    cd "$BENCH_DIR" || { echo "Error: No se pudo acceder al directorio $BENCH_DIR"; return; }

   # Directorio de salida para los resultados de cada tipo de predictor
    local OUTPUT_DIR_BASE="$BASE_DIR/Results"

    # Simulación para cada predictor estatico
    for PRED in "nottaken" "taken" "perfect"; do
        #local OUTPUT_DIR="${OUTPUT_DIR_BASE}/ResultsStatic_${BENCH}_${PRED}.txt"
        local OUTPUT_DIR="$BASE_DIR/Results/ResultsStatic_${BENCH}_${PRED}.txt"
        # Construir la linea de comandos para sim-outorder con el predictor
	#        local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
	# -mem:width $WIDTH -mem:lat $CYCLES $CONSECUTIVE \
	# -bpred $PRED -redir:sim $OUTPUT_DIR $EXE $COMMAND"
        local SIM_COMMAND="$SIMULATOR2 -fastfwd $FASTFWD -max:inst $MAX_INST \
	-bpred $PRED -redir:sim $OUTPUT_DIR $EXE $COMMAND"

        echo -e "\nExecuting simulation for $BENCH (Static Predictor: $PRED):"
        echo "$SIM_COMMAND"
        eval $SIM_COMMAND
        timer
        
        # Extraer y consolidar los resultados
        extract_results "$OUTPUT_DIR" "$BENCH" "$PRED" "N/A"
    done

    # Volver al directorio base después de la ejecución
    cd "$BASE_DIR" || { echo "Error: No se pudo regresar al directorio base $BASE_DIR"; exit 1; }
}

# Función para ejecutar simulaciones dinámicas de (BIMODAL, GSHARE, GAG y PAG)
execute_simulation_dynamic() {
    local BENCH=$1
    local EXE="$BASE_DIR/Benchmarks/$BENCH/exe/$BENCH.exe"
    local COMMAND="${BENCHMARKS[$BENCH]}"

    # Cambiar al directorio de referencia del benchmark
    local BENCH_DIR="$BASE_DIR/Benchmarks/$BENCH/data/ref"
    cd "$BENCH_DIR" || { echo "Error: No se pudo acceder al directorio $BENCH_DIR"; return; }

   # Directorio de salida para los resultados de cada tipo de predictor
    local OUTPUT_DIR_BASE="$BASE_DIR/Results"

    # Simulación para cada predictor dinámico con sus configuraciones específicas
    for PRED in "bimodal" "2lev_gshare" "2lev_gag" "2lev_pag"; do
    # for PRED in "2lev_gshare" "2lev_gag" "2lev_pag"; do
        local CONFIG_VALUES="${CONFIGURATIONS[$PRED]}"

        for CONFIG in $CONFIG_VALUES; do
            local OUTPUT_DIR="$BASE_DIR/Results/ResultsDynamic_${BENCH}_${PRED}_${CONFIG}.txt"
            
            # Construir la línea de comandos de acuerdo al tipo de predictor y configuración
            case $PRED in
                "bimodal")
                    local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
                    -mem:width $WIDTH -mem:lat $CYCLES $CONSECUTIVE \
                    -bpred bimod -bpred:bimod $CONFIG -redir:sim $OUTPUT_DIR $EXE $COMMAND"
                    ;;
                "2lev_gshare")
                    LOG2X=$(echo "l($CONFIG)/l(2)" | bc -l | awk '{print int($1)}')
                    if [ "$LOG2X" -lt 1 ]; then
                        LOG2X=1 # Fuerza 1 bit de historia como mínimo
                    fi
                    SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
                    -mem:width $WIDTH -mem:lat $CYCLES $CONSECUTIVE \
                    -bpred 2lev -bpred:2lev 1 $CONFIG $LOG2X 1 -redir:sim $OUTPUT_DIR $EXE $COMMAND"
                            ;;
                "2lev_gag")
                    LOG2X=$(echo "l($CONFIG)/l(2)" | bc -l | awk '{print int($1)}')
                    if [ "$LOG2X" -lt 1 ]; then
                        LOG2X=1 # Fuerza 1 bit de historia como mínimo
                    fi
                    SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
                    -mem:width $WIDTH -mem:lat $CYCLES $CONSECUTIVE \
                    -bpred 2lev -bpred:2lev 1 $CONFIG $LOG2X 0 -redir:sim $OUTPUT_DIR $EXE $COMMAND"
                    ;;
                "2lev_pag")
                    Y=${CONFIG%-*}
                    X=${CONFIG#*-}
                    LOG2X=$(echo "l($X)/l(2)" | bc -l | awk '{print int($1)}')
                    if [ "$LOG2X" -lt 1 ]; then
                        LOG2X=1 # Fuerza 1 bit de historia como mínimo
                    fi
                    SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
                    -mem:width $WIDTH -mem:lat $CYCLES $CONSECUTIVE \
                    -bpred 2lev -bpred:2lev $Y $X $LOG2X 0 -redir:sim $OUTPUT_DIR $EXE $COMMAND"
                    ;;
	    esac

            echo -e "\nExecuting simulation for $BENCH (Dynamic Predictor: $PRED with config $CONFIG):"
            echo "$SIM_COMMAND"
            eval $SIM_COMMAND
            timer
            
            # Extraer y consolidar los resultados
            extract_results "$OUTPUT_DIR" "$BENCH" "$PRED" "$CONFIG"
        done
    done

    # Volver al directorio base después de la ejecución
    cd "$BASE_DIR" || { echo "Error: No se pudo regresar al directorio base $BASE_DIR"; exit 1; }
}


for BENCH in "${!BENCHMARKS[@]}"; do
    execute_simulation_static "$BENCH"
done
for BENCH in "${!BENCHMARKS[@]}"; do
    execute_simulation_dynamic "$BENCH"
done

# Ejecutar simulaciones para todos los benchmarks
#for BENCH in "${!BENCHMARKS[@]}"; do
    #execute_simulation_static "$BENCH"
#done

timer
