{
  name: "tangle-deployments",
  customizations+: {
    vscode+: {
      extensions+: [
      ],
    },
  },
  postCreateCommand+: {
    "tangle-deployments-post-install": "bash ./.devcontainer/post_install.sh",
  },
}
