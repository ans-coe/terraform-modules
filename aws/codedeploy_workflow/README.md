# Terraform (Module) - AWS - Code Deploy Workflow

### Explanation

These modules function as a single system. This system is designed to take a repo containing CodeDeploy compatible code, upload this code to S3 via CodePipeline and then push this out to a list of ASGs. 

Specifically, this system is designed to work with instances in ASGs.

This is built in 2 parts:

- A build stage, which hooks into a CodeCommit repo, packages the code and uploads it to S3 via CodePipeline
- A deploy stage, which sets up CodeDeploy applications and triggers a pipeline when the S3 code is updated to push to CodeDeploy

The build stage was designed to run within an operations (ops) account, whereas the deploy stage was designed to run in the same account as the ASGs where the CodeDeploy code is executed. The deploy stage can be called multiple times with in different accounts meaning that you can have 1 centralised pipeline that deploy to many accounts based on branches within CodeCommit. EG: Commit to prod branch = deploy to prod CodeDeploy group.

This leads us onto why this is two modules instead of one. The deploy stage could run in any number of potential accounts however a single module must know ahead of time how many providers it needs so the only way to allow for an endless amount of deploy stages is to separate out the deploy stage from the build stage.