{
    description = "Flake para rodar os testes.";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        experiments.url = "github:Sacolle/experiments-nix"; 
        #experiments.url = "path:/home/colle/pcad-nix"; 
    };
    outputs = { self, nixpkgs, experiments }: 
    let
        system = "x86_64-linux"; 
        pkgs = import nixpkgs { inherit system; };

        star-fletcher-dir = "~/Star-Fletcher";
        scratch-folder = "$SCRATCH/$HOSTNAME";
        home-folder = "~/experimental-results/$HOSTNAME";
        absorb-width = 8;
        base-step = 0.0001;
        dt-output = base-step * 5;
        str = toString;

        experimentScript = experiments.lib.mkExperiment {
            inherit pkgs; 
            
            csvFile = ./experiments-cpu.csv;

            preamble = ''
                mkdir -p ${scratch-folder}
                mkdir -p ${home-folder}
            '';

            buildScript = ''
                pushd ${star-fletcher-dir}
                make
                popd
            '';
            
            bashRunFn = { WithIO, Size, Segmentation, Steps, Blocks, ... }: 
            let
                tmax = base-step * (pkgs.lib.strings.toInt Steps);
                filename = "${WithIO}-${Size}-${Segmentation}-${Steps}";
                stdout-file = "${scratch-folder}/stdout-${filename}.out";
                rsf-file = "${scratch-folder}/out-${filename}.rsf";
                rsf-at-file = "${rsf-file}@";
                prof-file = "prof_file_${filename}";
            in
            ''
                STARPU_TRACE_BUFFER_SIZE=2048 \
                STARPU_FXT_TRACE=1 \
                STARPU_FXT_PREFIX=${scratch-folder} \
                STARPU_FXT_SUFFIX=${prof-file} \
                OUTPUT_FOLDER=${scratch-folder} \
                OUTPUT_FILE=${filename} \
                ENABLE_IO=${str WithIO} \
                ${star-fletcher-dir}/main TTI ${Size} ${Size} ${Size} \
                ${str absorb-width} 12.5 12.5 12.5 \
                ${str base-step} ${str tmax} ${Segmentation} ${str dt-output} 2>&1 > ${stdout-file}

                cat ${stdout-file}

                chmod u+rw ${rsf-at-file}

                cp ${rsf-file} ${rsf-at-file} ${scratch-folder}/${prof-file}* ${stdout-file} ${home-folder}
            '';
        };
    in
    {
        packages.${system}.default = experimentScript;
    };
}
