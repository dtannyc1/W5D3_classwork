require_relative 'Question_follows'

puts
p QuestionFollows.all
p QuestionFollows.find_by_user_id(1)
p QuestionFollows.find_by_question_id(1)
new_question_like = QuestionFollows.new("question_id" => 3, "user_id" => 3)
new_question_like.create

puts
p QuestionFollows.all
new_question_like.user_id = 2
new_question_like.update

puts
p QuestionFollows.all
