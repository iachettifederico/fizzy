import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "auto-save" ]

  change(event) {
    this.autoSaveOutlet.change(event)
  }

  submit() {
    this.autoSaveOutlet.submit()
  }

  pasteFiles(event) {
    const files = event.clipboardData?.files
    if (!files?.length) return
    
    const editor = this.element.querySelector('house-md')
    if (!editor) return

    for (const file of files) {
      const upload = new CustomEvent('house-md:before-upload', {
        bubbles: true,
        detail: { file }
      })
      
      if (editor.dispatchEvent(upload)) {
        const uploadElement = document.createElement('house-md-upload')
        uploadElement.file = file
        uploadElement.uploadsURL = editor.dataset.uploadsUrl
        editor.appendChild(uploadElement)
      }
    }
  }
}
