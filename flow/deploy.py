from prefect import flow
from prefect.runner.storage import GitRepository
from prefect_github import GitHubCredentials


if __name__ == "__main__":

    """
    This code down below breakdown how to deploy flow, clone from github
    Uncomment if you wanna use it.
    """
    # source = GitRepository(
    #     branch="main",
    #     url=<"https://github.com/username/repository.git">,
    #     # credentials=GitHubCredentials.load(<blocks-token-github>)
    # )

    # flow.from_source(
    #     source=source,
    #     entrypoint="path/main.py:main_flow"
    # ).deploy(
    #     name="Github_Deployment",
    #     work_pool_name="WORKER-1",
    #     work_queue_name="Running_Manual",
    #     concurrency_limit=1,
    # )
    
    """
    This code down below breakdown how to deploy flow, clone from self hosted gitea
    Uncomment if you wanna use it.
    """
    # flow.from_source(
    #     source="http://<USERNAME GITEA>:<TOKEN ACCESS GITEA>@<IP Self Hosted Gitea>:<PORT>/repository.git",
    #     entrypoint="<path/main.py:main_flow>"
    # ).deploy(
    #     name="Gitea_Deployment",
    #     work_pool_name="WORKER-1",
    #     work_queue_name="Running_Manual",
    #     concurrency_limit=1,
    # )
