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
        
        experiment-name = "msamples-base";
        fletcher-name = "original";
        repo-local = "~/cuda-fletcher-base/fletcher-base/original";
        scratch-folder = "$SCRATCH/${experiment-name}/$HOSTNAME";
        fletcher-base-in-scratch = "${scratch-folder}/${fletcher-name}";
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
            
            csvFile = ./ex-cpu-msamples-base.csv;

            preamble = ''
                mkdir -p ${scratch-folder}
                mkdir -p ${home-folder}
                rsync -av --exclude=".git" ${repo-local} ${scratch-folder}
                
                CORES=$(grep -P '^core id' /proc/cpuinfo | sort -u | wc -l)
            '';

            buildScript = ''
                pushd ${fletcher-base-in-scratch}
                make
                popd
            '';
            
            bashRunFn = { replication, ... }: 
            let
                filename = "${replication}";
                stdout-file = "${scratch-folder}/stdout-${filename}.out";
            in
            ''
                OMP_NUM_THREADS=$CORES \
                OUTPUT_FOLDER=${scratch-folder} \
                OUTPUT_FILE=${filename} \
                ${fletcher-base-in-scratch}/ModelagemFletcher.exe TTI ${size} ${size} ${size} \
                ${str absorb-width} 12.5 12.5 12.5 \
                ${str base-step} ${str tmax} ${str dt-output} 2>&1 > ${stdout-file}

                cat ${stdout-file}

                cp ${stdout-file} ${home-folder}
            '';
        };
    in
    {
        packages.${system}.default = experimentScript;
    };
}
