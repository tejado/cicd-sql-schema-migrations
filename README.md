# Continuous schema migrations for SQL databases

This project demonstrates a CI/CD approach for handling daily SQL schema changes part of the development process. 
Two fundamental questions are getting adressed by this:

1. How do we define the SQL schema and changes between versions in code?
2. How do we approve schema changes and execute the subsequent migration continuously in a fast-changing environment?

The tools skeema and gh-ost will help to answer these questions in one of many other possible ways.
Skeema is a open source tool for managing schema changes in pure SQL. It allows us to generate an actionable diff from two schemas. With this, we have full transparency about changes in SQL files. 
Gh-ost is also open source and we will use it to execute the migration without any triggers and most important: online. 

Integrating these tools into GitHub Action pipelines (we will use two: one for pull requests and one for deployment, so the actual migration) can look like the following:

<p align="center">
  <img src="/doc/img/dev-process.png" alt="Development Process">
</p>

Currently only for MySQL and GitHub Actions, but the concepts can be applied to others as well.

## Usage

### Prerequisites

At first, a MySQL server has to be available. In this simple scenario, we are not using any testing or replica scenarios for the migration, so one single server is for this demo is sufficient.
The MySQL server has to be configured with `binlog_row_image=FULL`. Also it needs to be accessible by GitHub Actions (if you are not using any self-hosted runners), which can be achieved by enabling "Allow public access from Azure services and resources within Azure" ([more information](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking-public#allowing-all-azure-ip-addresses)).

Then create a new repository over the "Use this template" button or fork/clone it.
The GitHub Actions Pull Request and Deployment pipeline will create the necessary .skeema file (the configuration file for skeema) based on the repository secrets. You will need to set following secrets on your newly created repository:

<table>
    <thead>
        <tr>
            <th>Secret</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>MYSQL_PRODUCTION_HOST</td>
            <td rowspan=4>The MySQL server which is in this demo your "production" one. The schema migration will be automatically executed over gh-ost on this server. <br /><br /> The user requires certain privileges for the migration: <a href="https://github.com/github/gh-ost/blob/master/doc/requirements-and-limitations.md">gh-ost - Requirements and limitations</a> </td>
        </tr>
        <tr>
            <td>MYSQL_PRODUCTION_PORT</td>
        </tr>
        <tr>
            <td>MYSQL_PRODUCTION_USERNAME</td>
        </tr>
        <tr>
            <td>MYSQL_PRODUCTION_PASSWORD</td>
        </tr>
        <tr>
            <td>MYSQL_SCHEMA</td>
            <td>The database name of the application inside your MySQL server. Also used in the temporary database in the pull request pipeline.</td>
        </tr>
    </tbody>
</table>

Example:
<p align="center">
  <img src="/doc/img/github-secrets.png" alt="GitHub Secrets">
</p>

### Development flow

After setting up the prerequisites, you can suggest any changes over a pull request to the SQL files in the schema folder, e.g. adding a column. You will see that a pull-request pipeline will start and add a comment to your PR.

If you approve and merge the changes into your master branch, the deployment pipeline will start and executes gh-ost for ALTER TABLE statements on your configured database. CREATE TABLE or DROP TABLE statements are "simple" SQL changes and will NOT be executed with gh-ost.

> **_NOTE:_** The pipelines are defined in the [.github/workflows](https://github.com/tejado/cicd-sql-schema-migrations/tree/master/.github/workflows) folder. Because automated release and deployment processes (continuous deployment) combine your technology stack and requirements with the processual circumstances, they can differ greatly from application to application. If you introduce this process into your environment, think it through carefully and don't adopt it 1:1!

## Limitations
- Currently only for MySQL on Azure (the pipelines can be easily adjusted for non-Azure databases)
- Foreign keys are not supported by gh-ost. There are workarounds available. Please see [github/gh-ost/issues/331](https://github.com/github/gh-ost/issues/331)
- Your database needs to be reachable by GitHub Actions. If you are using an isolated network for your database, you can use GitHub Actions on [self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners).

## References
- [Automating MySQL schema migrations with GitHub Actions and more](https://github.blog/2020-02-14-automating-mysql-schema-migrations-with-github-actions-and-more/)
- [skeema GitHub repo](https://github.com/skeema/skeema)
- [gh-ost GitHub repo](https://github.com/github/gh-ost)
- [gh-mysql-tools GitHub repo](https://github.com/github/gh-mysql-tools/tree/master/skeefree)
