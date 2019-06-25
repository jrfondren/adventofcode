with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with GNAT.OS_Lib;
with Marble_Mania;

procedure Day9 is
   Players     : Positive;
   Last_Marble : Positive;
begin
   if Argument_Count /= 2 then
      Put_Line
        (Standard_Error,
         "usage: " & Command_Name & " <#players> <marble-worth>");
      GNAT.OS_Lib.OS_Exit (1);
   end if;
   Players     := Positive'Value (Argument (1));
   Last_Marble := Positive'Value (Argument (2));
   Put_Line
     (Positive'Image (Players) & " players; last marble is worth " &
      Positive'Image (Last_Marble) & " points: high score is " &
      Marble_Mania.Score_Count'Image
        (Marble_Mania.Play_Until (Players, Last_Marble)));
end Day9;
