# AC_Practica1

-- SPECS --

    - Intel Core i5-14400 (Lackluster core)
        Quantitat d'instruccions per cicle a tractar
            FETCH:
            DECODE:
            ISSUE:
            COMMIT:

        Mida Buffers emmagatzenament d'instruccions
            RUU: 320 instruccions
            LSQ: 72 instruccions

        Caché L1
            Manipulació separada inst y dades: SI
            L1I Mida: 32KB/Core P-Core (Performance Core)
                      64KB/Core E-Core (Efficiency Core)    
                Associativitat: 8 per P-Core. 8 per E-Core.
                Algoritme reemplaçament:
            
            L1D Mida: 48KB/Core P-Core (Performance Core)
                      32KB/Core E-Core (Efficiency Core)    
                Associativitat: 12 per P-Core. 8 per E-Core.
                Algoritme reemplaçament:

        Caché L2
            Manipulació separada inst y dades: NO
            Mida: 1280 KB/Core P-Core (Performance Core)
                  2MB Compartida E-Core (Efficiency Core)
            Associativitat: 10 per P-Core. 16 per E-Core
            Algoritme reemplaçament:
        
        Cores: 10 cores. 6 P-Cores y 4 E-Cores.

        Main Memory
            Amplada de banda: 76.8 GB/s
            Latència:

        Numero ALUs i multiplicació d'Integers:
        Numero ALUs i multiplicació coma flotant:
        Numero ports accés a memòria Caché L1:
        


    -AMD Ryzen 5 7600X (Zen 4 core)
        Quantitat d'instruccions per cicle a tractar
                FETCH: 8 (HE TROBAT QUE SON 6 ENLLOC DE 8, COMPROVA-HO XFA)
                DECODE: 6
                ISSUE: 10 ints 6 floats
                COMMIT: 6 

            Mida Buffers emmagatzenament d'instruccions
                RUU: 320 instruccions
                LSQ: 88 instruccions
            
            Caché L1
                Manipulació separada inst y dades: SI
                L1I Mida: 32KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament:
            
                L1D Mida: 32KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament:

            Caché L2
                Manipulació separada inst y dades: NO
                Mida: 1024KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament:
           
            Cores: 6 cores.

            Main Memory
                Amplada de banda: 83.2GB/s
                Latència:

            Numero ALUs i multiplicació d'Integers: ? - 10 ints
            Numero ALUs i multiplicació coma flotant: ? - 6 floats
            Numero ports accés a memòria Caché L1:

https://www.anandtech.com/show/17585/amd-zen-4-ryzen-9-7950x-and-ryzen-5-7600x-review-retaking-the-high-end/8
https://azrael.digipen.edu/~mmead/www/docs/IntroToIntelArch-TheBasics.pdf
https://www.elprocus.com/superscalar-processor/
https://www.inf.ed.ac.uk/teaching/courses/pa/Notes/lecture03-superscalars.pdf
https://www.cpuid.com/softwares/cpu-z.html
https://www.custompc.com/intel/core-i5-14400f-guide
https://www.google.com/search?q=deep+explanation+in+intel+architecture&rlz=1C5CHFA_enES1115ES1115&oq=deep+explanation+in+intel+architec&gs_lcrp=EgZjaHJvbWUqCQgBECEYChigATIGCAAQRRg5MgkIARAhGAoYoAEyCQgCECEYChigATIJCAMQIRgKGKABMgcIBBAhGJ8FMgcIBRAhGJ8FMgcIBhAhGJ8F0gEJMTM4MTVqMWo0qAIAsAIA&sourceid=chrome&ie=UTF-8
https://chipsandcheese.com/2024/09/15/discussing-amds-zen-5-at-hot-chips-2024/
https://www.profesionalreview.com/2022/10/13/amd-ryzen-5-7600x-review/


RUU (register update unit) = ROB (reorder buffer)

    **
        En un procesador superescalar, varias características determinan la cantidad de instrucciones que se pueden procesar simultáneamente en las etapas de FETCH, DECODE, ISSUE, y COMMIT. Estas características son:

        1. Ancho de Banda del Bus de Instrucciones (Instruction Fetch Bandwidth):
        En la etapa de FETCH, la cantidad de instrucciones que se pueden obtener del caché depende del ancho de banda del bus entre el caché L1 de instrucciones y el procesador. Procesadores con buses más anchos pueden obtener más instrucciones por ciclo, lo que incrementa el ancho del fetch.
        2. Número de Decodificadores:
        En la etapa de DECODE, el número de decodificadores determina cuántas instrucciones pueden ser decodificadas simultáneamente. Si el procesador tiene varios decodificadores, podrá manejar más instrucciones en paralelo. En procesadores x86, algunas instrucciones complejas pueden requerir más ciclos para decodificarse, mientras que en arquitecturas RISC, las instrucciones son más simples y uniformes, lo que facilita una decodificación más rápida.
        3. Unidades Funcionales y Puertos de Emisión (Functional Units and Issue Ports):
        En la etapa de ISSUE, la cantidad de unidades funcionales (como ALUs, unidades de coma flotante, etc.) y el número de puertos de emisión influyen en cuántas instrucciones pueden emitirse y asignarse para ejecución. Los procesadores superescalares suelen tener múltiples unidades funcionales para procesar varias instrucciones a la vez.
        4. Tamaño del Reorder Buffer (ROB):
        En la etapa de COMMIT, el tamaño del Reorder Buffer (ROB) es clave para determinar cuántas instrucciones pueden ser retiradas o completadas por ciclo. El ROB almacena las instrucciones que están en proceso de ejecución fuera de orden y garantiza que se completen en el orden correcto.
        5. Tamaño y Eficiencia del Pipeline:
        La longitud y la estructura del pipeline del procesador influyen en la capacidad de procesar múltiples instrucciones en las diferentes etapas simultáneamente. Un pipeline más eficiente con menos dependencias y mejores mecanismos de predicción de saltos permite que se procesen más instrucciones por ciclo sin retrasos por dependencias o fallos de predicción.
        6. Predicción de Saltos y Control de Dependencias:
        Un buen sistema de predicción de saltos y la capacidad de resolver dependencias de datos rápidamente permiten que más instrucciones puedan progresar a través del pipeline sin estancarse. Los errores de predicción o dependencias no resueltas disminuyen el número de instrucciones que avanzan en las etapas de FETCH y DECODE.
        7. Tamaño y Asociatividad del Caché:
        Un caché L1/L2 más grande y de mayor asociatividad reduce los fallos de caché, lo que aumenta la cantidad de instrucciones disponibles para ser procesadas en las etapas de FETCH y DECODE sin la necesidad de acceder a la memoria principal, que es más lenta.
    **

            Se supone la media de 32 bits(4 bytes) cada instruccion por el siguiente motivo:
            Los procesadores AMD Ryzen 5 7600X, como parte de la arquitectura Zen 4, utilizan una arquitectura CISC (Complex Instruction Set Computing), igual que los procesadores Intel basados en x86. Aunque las instrucciones x86 son de longitud variable y complejas, AMD también optimiza internamente descomponiendo algunas de estas instrucciones en microinstrucciones más simples, similares a las arquitecturas RISC, para mejorar la eficiencia y rendimiento, pero sigue siendo clasificado como CISC debido a la compatibilidad x86.