const core = require('@actions/core')
// const github = require('@actions/github')
const exec = require('@actions/exec')

function run() {
    // * 1) get some input values to work with
    const bucket = core.getInput('bucket', {required: true})
    const bucketRegion = core.getInput('bucket-region', {required: true})
    const distFolder = core.getInput('dist-folder', {required: true})

    // * 2) upload files
    const s3Uri = `s3://${bucket}`

    // * sync local folder files into s3 bucket folder
    exec.exec(`aws s3 sync ${distFolder} ${s3Uri} --region ${bucketRegion}`)

    const websiteUrl = `http://${bucket}.s3-website-${bucketRegion}.amazonaws.com`
    core.setOutput('website-url', websiteUrl)

    core.notice('Hello from my custom JS action!')
}

run()