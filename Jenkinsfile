pipeline {
  agent any
  stages {
    stage('Jenkins-file') {
      steps {
        git(url: 'https://github.com/Abdulrahman-Kazamel/terraform-test', branch: 'dev')
      }
    }

    stage('list files') {
      steps {
        sh '''ls
echo "hello from jenkins" >> /tmp/temp.txt
cat /tmp/temp.txt'''
      }
    }

  }
}