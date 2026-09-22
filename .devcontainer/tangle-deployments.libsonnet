{
  name: "tangle-deployments",
  customizations+: {
    vscode+: {
      extensions+: [
        "github.vscode-github-actions",
      ],
    },
  },
  postCreateCommand+: {
    "tangle-deployments-post-install": "bash ./.devcontainer/post_install.sh",
  },
}
