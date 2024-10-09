#!/bin/bash

# Obtener el directorio del script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ruta al simulador
SIMULATOR="$BASE_DIR/simplesim-3.0_ecx/sim-outorder"

# Parámetros comunes
FASTFWD=100000000
MAX_INST=100000000

# Parámetros de ejecución del procesador (basados en Intel Core i5-14400)
INT_FETCH_IFQSIZE=6
INT_DECODE_WIDTH=6
INT_ISSUE_WIDTH=6
INT_COMMIT_WIDTH=6
INT_RUU_SIZE=512
INT_LSQ_SIZE=256 #192

# Configuración de latencias para cachés
INT_IL2LAT=12
INT_DL2LAT=12
INT_IL1LAT=4
INT_DL1LAT=4

# Configuración de cachés L1 y L2
INT_IL1_ASOC=8
INT_DL1_ASOC=16
INT_DL2_ASOC=8

INT_IL1_SIZE=32  # KB
INT_IL1_BSIZE=64 # Bytes

INT_DL1_SIZE=48  # KB
INT_DL1_BSIZE=64 # Bytes

INT_UL2_SIZE=1280 # KB
INT_UL2_BSIZE=64  # Bytes

INT_FIRST_CHUNK=56
INT_INTER_CHUNK=1
INT_MEM_WIDTH=16

INT_ALUI=4
INT_ALUF=2
INT_MULTI=2
INT_MULTF=1

# Parámetros de ejecución del procesador (basados en AMD Ryzen 5 7600X)
AMD_FETCH_IFQSIZE=6
AMD_DECODE_WIDTH=4
AMD_ISSUE_WIDTH=6
AMD_COMMIT_WIDTH=6
AMD_RUU_SIZE=256 #320
AMD_LSQ_SIZE=128 #136

# Configuración de latencias para cachés
AMD_IL2LAT=4
AMD_DL2LAT=4
AMD_IL1LAT=1
AMD_DL1LAT=1

# Configuración de cachés L1 y L2
AMD_IL1_ASOC=8
AMD_DL1_ASOC=8
AMD_DL2_ASOC=8

AMD_IL1_SIZE=32  # KB
AMD_IL1_BSIZE=64 # Bytes

AMD_DL1_SIZE=32  # KB
AMD_DL1_BSIZE=64 # Bytes

AMD_UL2_SIZE=1024 # KB
AMD_UL2_BSIZE=64  # Bytes

AMD_FIRST_CHUNK=64
AMD_INTER_CHUNK=1
AMD_MEM_WIDTH=16

AMD_ALUI=4
AMD_ALUF=2
AMD_MULTI=1
AMD_MULTF=2

# Función para calcular el número más cercano que sea potencia de 2
nearsest_power2() {
    local n=$1
    local power=1
    while (( power < n )); do
        power=$(( power * 2 ))
    done
    echo $power
}

# Cálculo del número de conjuntos (sets) para cada caché y ajustar a potencia de 2
INT_IL1_SETS=$(nearsest_power2 $(( ($INT_IL1_SIZE * 1024) / ($INT_IL1_BSIZE * $INT_IL1_ASOC) )))
INT_DL1_SETS=$(nearsest_power2 $(( ($INT_DL1_SIZE * 1024) / ($INT_DL1_BSIZE * $INT_DL1_ASOC) )))
INT_UL2_SETS=$(nearsest_power2 $(( ($INT_UL2_SIZE * 1024) / ($INT_UL2_BSIZE * $INT_DL2_ASOC) )))

AMD_IL1_SETS=$(nearsest_power2 $(( ($AMD_IL1_SIZE * 1024) / ($AMD_IL1_BSIZE * $AMD_IL1_ASOC) )))
AMD_DL1_SETS=$(nearsest_power2 $(( ($AMD_DL1_SIZE * 1024) / ($AMD_DL1_BSIZE * $AMD_DL1_ASOC) )))
AMD_UL2_SETS=$(nearsest_power2 $(( ($AMD_UL2_SIZE * 1024) / ($AMD_UL2_BSIZE * $AMD_DL2_ASOC) )))

# Obtener el tiempo de inicio
start_time=$(date +%s)

# Benchmarks y sus comandos específicos
declare -A BENCHMARKS
BENCHMARKS["ammp"]="ammp < ammp.in > ammp.out 2> ammp.err"
BENCHMARKS["applu"]="applu < applu.in > applu.out 2> applu.err"
BENCHMARKS["eon"]="chair.control.rushmeier chair.camera chair.surfaces chair.rushmeier.ppm ppm pixels_out.rushmeier > rushmeier_log.out 2> rushmeier_log.err"
BENCHMARKS["equake"]="equake < inp.in > inp.out 2> inp.err"
BENCHMARKS["vpr"]="net.in arch.in place.out dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2 > place_log.out 2> place_log.err"

# Función para ejecutar una simulación
execute_simulation() {
    local BENCH=$1
    local EXE="$BASE_DIR/Benchmarks/$BENCH/exe/$BENCH.exe"
    local COMMAND="${BENCHMARKS[$BENCH]}"

    # Cambiar al directorio de referencia del benchmark
    local BENCH_DIR="$BASE_DIR/Benchmarks/$BENCH/data/ref"
    cd "$BENCH_DIR" || { echo "Error: No se pudo acceder al directorio $BENCH_DIR"; return; }

    # Directorio de salida para Intel
    local OUTPUT_DIR="$BASE_DIR/Upgrades/RAM/ResultsINT_${BENCH}.txt"
    # Construir la línea de comandos para sim-outorder (Intel)
    local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
-fetch:ifqsize $INT_FETCH_IFQSIZE -decode:width $INT_DECODE_WIDTH -issue:width $INT_ISSUE_WIDTH -commit:width $INT_COMMIT_WIDTH \
-ruu:size $INT_RUU_SIZE -lsq:size $INT_LSQ_SIZE \
-cache:il1 il1:${INT_IL1_SETS}:${INT_IL1_BSIZE}:${INT_IL1_ASOC}:l -cache:il1lat $INT_IL1LAT \
-cache:dl1 dl1:${INT_DL1_SETS}:${INT_DL1_BSIZE}:${INT_DL1_ASOC}:l -cache:dl1lat $INT_DL1LAT \
-cache:dl2 ul2:${INT_UL2_SETS}:${INT_UL2_BSIZE}:${INT_DL2_ASOC}:l -cache:dl2lat $INT_DL2LAT \
-mem:lat $INT_FIRST_CHUNK $INT_INTER_CHUNK -mem:width $INT_MEM_WIDTH \
-res:ialu $INT_ALUI -res:fpalu $INT_ALUF \
-res:imult $INT_MULTI -res:fpmult $INT_MULTF \
-redir:sim $OUTPUT_DIR $EXE $COMMAND"

    echo "Executing simulation for $BENCH (INTEL):"
    echo "$SIM_COMMAND"
    eval $SIM_COMMAND

    # Directorio de salida para AMD
    local OUTPUT_DIR="$BASE_DIR/Upgrades/RAM/ResultsAMD_${BENCH}.txt"
    # Construir la línea de comandos para sim-outorder (AMD)
    local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
-fetch:ifqsize $AMD_FETCH_IFQSIZE -decode:width $AMD_DECODE_WIDTH -issue:width $AMD_ISSUE_WIDTH -commit:width $AMD_COMMIT_WIDTH \
-ruu:size $AMD_RUU_SIZE -lsq:size $AMD_LSQ_SIZE \
-cache:il1 il1:${AMD_IL1_SETS}:${AMD_IL1_BSIZE}:${AMD_IL1_ASOC}:l -cache:il1lat $AMD_IL1LAT \
-cache:dl1 dl1:${AMD_DL1_SETS}:${AMD_DL1_BSIZE}:${AMD_DL1_ASOC}:l -cache:dl1lat $AMD_DL1LAT \
-cache:dl2 ul2:${AMD_UL2_SETS}:${AMD_UL2_BSIZE}:${AMD_DL2_ASOC}:l -cache:dl2lat $AMD_DL2LAT \
-mem:lat $AMD_FIRST_CHUNK $AMD_INTER_CHUNK -mem:width $AMD_MEM_WIDTH \
-res:ialu $AMD_ALUI -res:fpalu $AMD_ALUF \
-res:imult $AMD_MULTI -res:fpmult $AMD_MULTF \
-redir:sim $OUTPUT_DIR $EXE $COMMAND"
    
    echo "Executing simulation for $BENCH (AMD):"
    echo "$SIM_COMMAND"
    eval $SIM_COMMAND

    # Volver al directorio base después de la ejecución
    cd "$BASE_DIR" || { echo "Error: No se pudo regresar al directorio base $BASE_DIR"; exit 1; }
}

# Ejecutar simulaciones para todos los benchmarks
for BENCH in "${!BENCHMARKS[@]}"; do
    execute_simulation "$BENCH"
done

# Obtener el tiempo de finalización
end_time=$(date +%s)

# Calcular la diferencia de tiempo
execution_time=$((end_time - start_time))

# Convertir el tiempo a minutos y segundos
minutes=$((execution_time / 60))
seconds=$((execution_time % 60))

# Imprimir el tiempo de ejecución en formato min:seg
echo "Tiempo total de ejecución: $minutes min $seconds seg"
