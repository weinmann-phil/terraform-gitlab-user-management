gitlab_token = "glpat-ukn8FTJnst_bAwN_EgAe"
gitlab_public_host = "http://localhost"
gitlab_users = [
  {
    email = "alan.turing@test.software",
    is_external = false,
    is_admin = true,
    membership = [
      {
        project = "test-group/project01"
      }
    ]
  },
  {
    email = "kip.thorne@test.software",
    is_external = true,
    is_admin = false,
    membership = [
      {
        project = "test-group/project01"
      },
      {
        project = "test-group/project02"
      },
      {
        project = "test-group/project03"
      },
    ]
  },
  {
    email = "bernd.seidensticker@test.software",
    is_external = false,
    is_admin = false,
    membership = [
      {
        project = "test-group/project02"
      },
      {
        project = "test-group/project01",
        access_level = "maintainer"
      },
    ]
  },
  {
    email = "carl.sagan@test.software",
    is_external = true,
    is_admin = true,
    membership = [
      {
        project = "test-group/project02",
        access_level = "maintainer"
      }
    ]
  }
]
