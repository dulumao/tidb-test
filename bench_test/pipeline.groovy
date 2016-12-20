node('ucloud29'){
    def workspace = pwd()
    env.GOPATH = "${workspace}/go"
    env.GOROOT = "/usr/local/go"
    env.PATH = "${workspace}/go/bin:${env.GOROOT}/bin:${env.PATH}"
    def pingcap = "${workspace}/go/src/github.com/pingcap"
    def tidb_path = "${pingcap}/tidb" 
    def tikv_path = "${pingcap}/tikv"
    def pd_path = "${pingcap}/pd"
    def tidb_test_path = "${pingcap}/tidb_test"
    def bench_path= "/data/bench-test"
    def githash_tidb, githash_tikv, githash_pd

    catchError {
        stage 'SCM Checkout'
         // tikv
        checkout([$class: 'GitSCM', branches: [[name: 'origin/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'go/src/github.com/pingcap/tikv']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c43085fe-5f73-4c22-b7df-a9dedf6a694a', url: 'git@github.com:pingcap/tikv.git']]])
         // tidb
        checkout([$class: 'GitSCM', branches: [[name: 'origin/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'go/src/github.com/pingcap/tidb']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c43085fe-5f73-4c22-b7df-a9dedf6a694a', url: 'git@github.com:pingcap/tidb.git']]])
         // pd
         checkout([$class: 'GitSCM', branches: [[name: 'origin/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'go/src/github.com/pingcap/pd']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c43085fe-5f73-4c22-b7df-a9dedf6a694a', url: 'git@github.com:pingcap/pd.git']]])
        // tidb-test 
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'origin/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'go/src/github.com/pingcap/tidb-test']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c43085fe-5f73-4c22-b7df-a9dedf6a694a', url: 'git@github.com:pingcap/tidb-test.git']]]

        try{
         stage 'Build'
            sh """
            echo "building TiDB..."
            cd ${tidb_path} && make
            cp -f ${tidb_path}/bin/tidb-server ${bench_path}/bin/bench-tidb-server
            echo "build TiDB OK"
            """
            githash_tidb = sh(returnStdout: true, script: """cd ${tidb_path} && git rev-parse HEAD""").trim()
        
            sh """
            echo "building PD..."
            cd ${pd_path} && make
            cp -f ${pd_path}/bin/pd-server ${bench_path}/bin/bench-pd-server
            echo "build PD OK"
            """
            githash_pd = sh(returnStdout: true, script: """cd ${pd_path} && git rev-parse HEAD""").trim()
            sh """
            echo "building TiKV..."
            cd ${tikv_path}
            ROCKSDB_SYS_STATIC=1 make clean release
            cp -f ${tikv_path}/bin/tikv-server ${bench_path}/bin/bench-tikv-server
            echo "build TiKV OK"
            """
            githash_tikv = sh(returnStdout: true, script: """cd ${tikv_path} && git rev-parse HEAD""").trim()
         stage 'Run Cluster'
             sh """
             cd ${bench_path}
             ./run_clusters.sh
            """
         stage 'BenchKV Test'
             sh """
             cd ${bench_path}/benchkv-test
             go build
             TIDB_VERSION=${githash_tidb} TIKV_VERSION=${githash_tikv} PD_VERSION=${githash_pd} ./benchkv-test   
            """

         stage 'BenchCount Test'
             sh """
             cd ${bench_path}/benchcount-test
             go build
             TIDB_VERSION=${githash_tidb} TIKV_VERSION=${githash_tikv} PD_VERSION=${githash_pd} ./benchcount-test   
            """

         stage 'BenchOltp Test'
             sh """
             cd ${bench_path}/bench-oltp
             go build
             TIDB_VERSION=${githash_tidb} TIKV_VERSION=${githash_tikv} PD_VERSION=${githash_pd} ./bench-oltp
            """
         }catch (err) {
            echo 'Test Error.'
            throw err
        } finally {
            echo 'Test Finish'
            sh """
            ${bench_path}/kill.sh
            """
        }
    }

    if(currentBuild.getResult().toString()  == 'FAILURE') {
        slackSend channel: '#dt',
        message: "failed to bench test, ${env.JOB_NAME}, ${env.BUILD_NUMBER}, ${env.BUILD_URL}",
        teamDomain: 'pingcap',
        token: '5Q0QsqbHRlXtrvFgFD2nF3u8'
    }

    step([$class: 'Mailer', notifyEveryUnstableBuild: true, recipients: 'test@pingcap.com', sendToIndividuals: false])
}
