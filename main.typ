#import "exam_template.typ": exam
#import sys.inputs.questions: exam_content
#import "header-en.typ": header-top as header

#let custom_header = header.with(
  course_code: "NNN101",
  course_name: "Introduction to Programming",
  group: "",
  instructor: "Dr. No",
  exam_duration: "60 mins",
  exam_date: "Nov 13th, 2024",
  exam_type: "1.Midterm",
  department: "",
  term: "2024-2025",
  semester: "FALL"
)

#exam_content(exam.with(
  custom_header: custom_header,
  booklet_name: sys.inputs.booklet  // Pass booklet_name directly to exam template
))
