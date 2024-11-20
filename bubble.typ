#import "@preview/cetz:0.3.1"

#let make-bubble-sheet(num-choices: 5, total-questions: 30, questions-per-col: 8) = {
  // Calculate derived values
  let letters = range(num-choices).map(i => str.from-unicode(65+i))
  let full-cols = calc.floor(total-questions / questions-per-col)
  let remaining-questions = calc.rem(total-questions,questions-per-col)
  let spacing-x = 4.5  // Space between columns
  
  cetz.canvas({
    import cetz.draw: *

    // Set default styles
    set-style(
      stroke: 0.4pt,
    )

    // Function to draw one row of bubbles
    let draw-row(x, y, num) = {
      // Draw question number
      content((x - 0.5, y), str(num) + ".", anchor: "east")

      // Draw circles with letters
      for i in range(num-choices) {
        let cx = x + i * 0.6

        // Draw circle
        circle((cx, y), radius: 0.25)

        // Draw letter
        content((cx, y), letters.at(i), anchor: "center")
      }
    }

    // Draw full columns
    for col in range(full-cols) {
      for row in range(questions-per-col) {
        let question-num = col * questions-per-col + row + 1
        draw-row(1 + col * spacing-x, -row * 0.7, question-num)
      }
    }

    // Draw remaining questions if any
    if remaining-questions > 0 {
      for row in range(remaining-questions) {
        let question-num = full-cols * questions-per-col + row + 1
        draw-row(1 + full-cols * spacing-x, -row * 0.7, question-num)
      }
    }
  })
}

#let sheet = make-bubble-sheet
