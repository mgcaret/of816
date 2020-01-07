testing OF816 words

hex

t{ 0 bsx -> 0 }t
t{ 7f bsx -> 7f }t
t{ 80 bsx -> -80 }t
t{ ff bsx -> -1 }t

t{ 0 wsx -> 0 }t
t{ 7fff wsx -> 7fff }t
t{ 8000 wsx -> -8000 }t
t{ ffff wsx -> -1 }t
