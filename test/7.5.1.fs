testing 7.5.1 Automatic stack display

t{ showstack -> }t \ expect:"{ 0 : } OK"
5 \ expect:"{ 1 : 5 } OK"
drop
t{ noshowstack -> }t
t{ -> }t \ expect " OK"

