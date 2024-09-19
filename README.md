# AC_Practica1

-- SPECS --

    - Intel Core i5-14400 (Lackluster core)
        Quantitat d'instruccions per cicle a tractar
            FETCH:
            DECODE:
            ISSUE:
            COMMIT:

        Mida Buffers emmagatzenament d'instruccions
            RUU:
            LSQ:
        
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
                FETCH: 8
                DECODE: 6
                ISSUE: 10 ints 6 floats
                COMMIT: 

            Mida Buffers emmagatzenament d'instruccions
                RUU: 320 instruccions
                LSQ: 88
            
            Caché L1
                Manipulació separada inst y dades: si
                Mida: 32KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament:

            Caché L2
                Manipulació separada inst y dades: si
                Mida: 1024KB/Core
                Associativitat: 8-way
                Algoritme reemplaçament:
            
            Main Memory
                Amplada de banda: 83.2GB/s
                Latència:

            Numero ALUs i multiplicació d'Integers: ? - 10 ints
            Numero ALUs i multiplicació coma flotant: ? - 6 floats
            Numero ports accés a memòria Caché L1:

https://www.anandtech.com/show/17585/amd-zen-4-ryzen-9-7950x-and-ryzen-5-7600x-review-retaking-the-high-end/8
https://azrael.digipen.edu/~mmead/www/docs/IntroToIntelArch-TheBasics.pdf

RUU (register update unit) = ROB (reorder buffer)
