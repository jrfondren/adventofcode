package body Marble_Mania is
   procedure Start (Game : in out Circle_Game) is
   begin
      Game.Board.Append (0);
      Game.Current := Game.Board.First;
      Game.Round   := 1;
   end Start;

   procedure Play (Player : in Positive; Game : in out Circle_Game) is
      procedure Next is
         use Nat_List;
      begin
         if Game.Current = Game.Board.Last then
            Game.Current := Game.Board.First;
         else
            Nat_List.Next (Game.Current);
         end if;
      end Next;
      procedure Previous is
         use Nat_List;
      begin
         if Game.Current = Game.Board.First then
            Game.Current := Game.Board.Last;
         else
            Nat_List.Previous (Game.Current);
         end if;
      end Previous;
      procedure Insert_After is
         use Nat_List;
      begin
         if Game.Current = Game.Board.Last then
            Game.Board.Append (Game.Round);
            Game.Current := Game.Board.Last;
         else
            Nat_List.Next (Game.Current);
            Game.Board.Insert
              (Before   => Game.Current, New_Item => Game.Round,
               Position => Game.Current);
         end if;
      end Insert_After;
      procedure Delete is
         use Nat_List;
         C : Cursor;
      begin
         if Game.Current = Game.Board.Last then
            Game.Board.Delete_Last;
            Game.Current := Game.Board.First;
         elsif Game.Current = Game.Board.First then
            Game.Board.Delete_First;
            Game.Current := Game.Board.First;
         else
            C := Nat_List.Next (Game.Current);
            Game.Board.Delete (Game.Current);
            Game.Current := C;
         end if;
      end Delete;
      Scoring : constant Boolean := Game.Round mod 23 = 0;
   begin
      if Scoring then
         for J in 1 .. 7 loop
            Previous;
         end loop;
         Game.Scores (Player) :=
           Game.Scores (Player) + Score_Count (Game.Round) +
           Score_Count (Nat_List.Element (Game.Current));
         Delete;
      else
         Next;
         Insert_After;
      end if;
      Game.Round := Game.Round + 1;
   end Play;

   function Play_Until (Players : in Positive;
      Last_Marble               : in Positive) return Score_Count
   is
      Game   : Circle_Game (Players);
      Player : Positive    := 1;
      Max    : Score_Count := 1;
   begin
      Start (Game);
      while Game.Round /= Last_Marble loop
         Play (Player, Game);
         Player := (if Player + 1 > Players then 1 else Player + 1);
      end loop;
      for J of Game.Scores loop
         if J > Max then
            Max := J;
         end if;
      end loop;
      return Max;
   end Play_Until;
end Marble_Mania;
