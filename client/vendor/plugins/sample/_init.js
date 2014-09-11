//jshint browser: true, strict: false
if (typeof window.plugins !== "object") {
  window.plugins = {};
}
window.plugins.sample = {
  name: "Sample JS",
  active: true,
  onAdd: {
    /**
     * Should return true if plugin applies on added subtree
     *
     * @param {DOMNode} root node of added subtree
     */
    condition: function (node) {
      return false;
    },
    /**
     * Perform action on added subtree
     *
     * @param {DOMNode} root node of added subtree
     */
    action: function (node) {
    }
  },
  /**
   * Called when plugin is activated
   */
  onActivate: function () {
    console.log('Plugin sample activated');
  },
  /**
   * Called when plugin is deactivated
   */
  onDeactivate: function () {
    console.log('Plugin sample deactivated');
  }
};
