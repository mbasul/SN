-- Creating a GitHub repository stage
--          https://docs.snowflake.com/developer-guide/git/git-setting-up: https://docs.snowflake.com/developer-guide/git/git-setting-up

-- ===========================================================================================
-- Create a secret with credentials for authenticating
use role SECURITYADMIN;
create role SNGIT_ADMIN_SECRET;
grant create secret on schema METROPT2.PUBLIC to role SNGIT_ADMIN_SECRET;
-- revoke create secret on schema METROPT2.PUBLIC from role SNGIT_ADMIN_SECRET;
grant role SNGIT_ADMIN_SECRET to role SECURITYADMIN;

use role SYSADMIN;
grant usage on database METROPT2 to role SNGIT_ADMIN_SECRET;
grant usage on schema METROPT2.PUBLIC to role SNGIT_ADMIN_SECRET;

-- ---------------------------------------------------------------------------------
use role SNGIT_ADMIN_SECRET;
use database METROPT2;
use schema METROPT2.PUBLIC;

create or replace secret SNGIT_GITHUB_SECR_MBASUL
    type = password
    username = 'MBASUL'
    password = 'OluNF0oPDMQo#jbqYJml'
;
-- drop secret SNGIT_GITHUB_MBASUL;
show secrets;


-- ===========================================================================================
use role SECURITYADMIN;
create role SNGIT_ADMIN_GIT;
use role ACCOUNTADMIN;
grant create integration on account to role SNGIT_ADMIN_GIT;

use role SYSADMIN;
grant usage on database METROPT2 to role SNGIT_ADMIN_GIT;
grant usage on schema METROPT2.PUBLIC to role SNGIT_ADMIN_GIT;

use role SNGIT_ADMIN_SECRET;
grant usage on secret SNGIT_GITHUB_SECR_MBASUL to role SNGIT_ADMIN_GIT;
-- revoke role SNGIT_ADMIN_GIT from role SYSADMIN;

use role SNGIT_ADMIN_GIT;
create or replace api integration SNGIT_GITHUB_INTEG_MBASUL
    api_provider = git_https_api
    api_allowed_prefixes = ('https://github.com/mbasul')
    allowed_authentication_secrets = (SNGIT_GITHUB_SECR_MBASUL)
    enabled = true
;

show roles in account;
show api integrations;


-- ===========================================================================================
use role SECURITYADMIN;
grant usage on integration SNGIT_GITHUB_INTEG_MBASUL to role SNGIT_ADMIN_GIT;
grant create git repository on schema METROPT2.PUBLIC to role SNGIT_ADMIN_GIT;

use role SNGIT_ADMIN_GIT;
create or replace git repository SNGIT_REPOS_GITHUB_MBASUL
    api_integration = SNGIT_GITHUB_INTEG_MBASUL
    git_credentials = SNGIT_GITHUB_SECR_MBASUL
    origin = 'https://github.com/mbasul/SN'
;

show integrations;
show git repositories;
describe git repository SNGIT_REPOS_GITHUB_MBASUL;
