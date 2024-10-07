# AC_Practica1

-- SPECS --

    - Intel Core i5-14400 (Lackluster core)
        Quantitat d'instruccions per cicle a tractar per cada etapa (IPC - k-via = 6)            
            (no se da la información, pero como CPU tipo Raptor-Lake, se supone 6 instrucciones en cada etapa)
            FETCH: 6
            DECODE: 6 (6 decoder)
            ISSUE: 6 (4 Integers & 2 Floats)
            COMMIT: 6

            k-via: 6

        Mida Buffers emmagatzenament d'instruccions
            RUU: 512
            LSQ: 192

        USAR P core.
        Caché L1 80KB (32KB + 48KB P cores)
            Manipulació separada inst y dades: SI
            L1I Mida: 32KB/Core P-Core (Performance Core)
                      64KB/Core E-Core (Efficiency Core)    
                Associativitat: 8 per P-Core. 8 per E-Core.
                Algoritme reemplaçament: LRU (Least Recently Used)
            
            L1D Mida: 48KB/Core P-Core (Performance Core)
                      32KB/Core E-Core (Efficiency Core)    
                Associativitat: 12 per P-Core. 8 per E-Core.
                Algoritme reemplaçament: LRU (Lease Recently Used)

        Caché L2
            Manipulació separada inst y dades: NO
            Mida: 1280 KB/Core P-Core (Performance Core) (1.25MB)
                  2MB Compartida E-Core (Efficiency Core)
            Associativitat: 10 per P-Core. 16 per E-Core -( 16vias)
            Algoritme reemplaçament: LRU (Lease Recently Used)
        
        Cores: 10 cores. 6 P-Cores y 4 E-Cores.
        sets 64.

        Main Memory
            Amplada de banda: 76.8 GB/s - (16B / ciclo)
            Latència: 4800 MT/s (DDR5)
        CAS latency (PC componentes)

        Numero ALUs i multiplicació d'Integers: 4 (P-core) y 2 (E-core) - (5-1)
        Numero ALUs i multiplicació coma flotant: 2 (P-core) y 1 (E-core) - (2-2)
        Numero ports accés a memòria Caché L1: 2 ports (load). 1 port (store) - (6)
        


    -AMD Ryzen 5 7600X (Zen 4 core)
        Quantitat d'instruccions per cicle a tractar per cada etapa (IPC - k-via)
                FETCH: 6
                DECODE: 4
                ISSUE: 6 (4 Integers & 2 Floats)
                COMMIT: 6 

            Mida Buffers emmagatzenament d'instruccions
                RUU: 320 instruccions
                LSQ: 136 instructions entry
            
            Caché L1
                Manipulació separada inst y dades: SI
                L1I Mida: 32KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament: LRU (Lease Recently Used)
            
                L1D Mida: 32KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament: LRU (Lease Recently Used)

            Caché L2
                Manipulació separada inst y dades: NO
                Mida: 1024KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament: LRU (Lease Recently Used)
           
            Cores: 6 cores.

            Main Memory
                Amplada de banda: 83.2GB/s - (!
                Latència: 5200 MT/s (DDR5)

            Numero ALUs i multiplicació d'Integers: 4 y 1
            Numero ALUs i multiplicació coma flotant: 2 y 2
            Numero ports accés a memòria Caché L1: 2 ports (load). 1 port (store)

FONTS:
------------------------------------------------------------------------------------------------------------------------------------
https://azrael.digipen.edu/~mmead/www/docs/IntroToIntelArch-TheBasics.pdf -> INTEL
https://www.custompc.com/intel/core-i5-14400f-guide -> INTEL
https://ark.intel.com/content/www/us/en/ark/products/236788/intel-core-i5-processor-14400-20m-cache-up-to-4-70-ghz.html -> INTEL

https://chipsandcheese.com/2022/11/05/amds-zen-4-part-1-frontend-and-execution-engine/ -> AMD
https://www.techpowerup.com/cpu-specs/ryzen-5-7600x.c2849 -> AMD
https://www.profesionalreview.com/2022/10/13/amd-ryzen-5-7600x-review/ -> AMD
https://www.anandtech.com/show/17585/amd-zen-4-ryzen-9-7950x-and-ryzen-5-7600x-review-retaking-the-high-end/8 -> AMD

https://hmc-tech.com/cpu/intel_core_i5_14400-vs-amd_ryzen_5_7600x-vs-amd_ryzen_5_9600x -> COMPARISON BTW THEM 2

https://chat.openai.com -> Comparació de resultats
-------------------------------------------------------------------------------------------------------------------------------------

RUU (register update unit) = ROB (reorder buffer)

    Se supone la media de 32 bits(4 bytes) cada instruccion por el siguiente motivo:
    Los procesadores AMD Ryzen 5 7600X, como parte de la arquitectura Zen 4, utilizan una arquitectura CISC (Complex Instruction Set Computing), igual que los procesadores Intel basados en x86. Aunque las instrucciones x86 son de longitud variable y complejas, AMD también optimiza internamente descomponiendo algunas de estas instrucciones en microinstrucciones más simples, similares a las arquitecturas RISC, para mejorar la eficiencia y rendimiento, pero sigue siendo clasificado como CISC debido a la compatibilidad x86.
