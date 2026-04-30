{
    description = "Flake para rodar os testes.";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        experiments.url = "github:Sacolle/experiments-nix"; 
    };
    outputs = { self, nixpkgs, experiments }: 
    let
        system = "x86_64-linux"; 
        pkgs = import nixpkgs { inherit system; };
        
        experiment-name = "msamples-max-threads";
        repo-name = "Star-Fletcher";
        star-fletcher-dir = "~/${repo-name}";
        scratch-folder = "$SCRATCH/${experiment-name}/$HOSTNAME";
        star-fletcher-in-scratch = "${scratch-folder}/${repo-name}";
        home-folder = "~/experimental-results/${experiment-name}/$HOSTNAME";
        absorb-width = 8;
        base-step = 0.0001;
        dt-output = base-step * 5;
        max-iterations = 40;
        tmax = base-step * max-iterations;
        str = toString;
        size = str (120 - 2 * (4 + absorb-width));

        experimentScript = experiments.lib.mkExperiment {
            inherit pkgs; 
            
            csvFile = ./ex-cpu-msamples.csv;

            preamble = ''
                mkdir -p ${scratch-folder}
                mkdir -p ${home-folder}
                rsync -av --exclude=".git" ${star-fletcher-dir} ${scratch-folder}

                THREADS=$(nproc)
            '';

            buildScript = ''
                pushd ${star-fletcher-in-scratch}
                make
                popd
            '';
            
            bashRunFn = { WithIO, Segmentation, Blocks, ... }: 
            let
                filename = "${WithIO}-${Segmentation}-${builtins.substring 1 (-1) Blocks}";
                stdout-file = "${scratch-folder}/stdout-${filename}.out";
                rsf-file = "${scratch-folder}/out-${filename}.rsf";
                rsf-at-file = "${rsf-file}@";
            in
            ''
                STARPU_NCPU=$THREADS \
                OUTPUT_FOLDER=${scratch-folder} \
                OUTPUT_FILE=${filename} \
                ENABLE_IO=${str WithIO} \
                ${star-fletcher-in-scratch}/main TTI ${size} ${size} ${size} \
                ${str absorb-width} 12.5 12.5 12.5 \
                ${str base-step} ${str tmax} ${Segmentation} ${str dt-output} 2>&1 > ${stdout-file}

                cat ${stdout-file}

                chmod u+rw ${rsf-at-file}

                cp ${stdout-file} ${home-folder}
            '';
        };
    in
    {
        packages.${system}.default = experimentScript;
    };
}
