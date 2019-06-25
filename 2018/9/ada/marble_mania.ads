with Ada.Containers.Doubly_Linked_Lists; use Ada.Containers;

package Marble_Mania is
   package Nat_List is new Ada.Containers.Doubly_Linked_Lists (Natural);
   type List_Ptr is access all Nat_List.List;
   type Score_Count is mod 2**64;
   type Player_Scores is array (Positive range <>) of Score_Count;

   type Circle_Game (Players : Positive) is tagged record
      Round   : Natural                      := 0;
      Current : Nat_List.Cursor;
      Scores  : Player_Scores (1 .. Players) := (others => 0);
      Board   : not null List_Ptr            := new Nat_List.List;
   end record;

   procedure Start (Game : in out Circle_Game) with
      Pre  => Game.Board.Length = 0,
      Post => Game.Board.Length = 1 and Game.Round = 1;
   procedure Play (Player : in Positive; Game : in out Circle_Game) with
      Pre  => Player <= Game.Scores'Last and Game.Board.Length > 0,
      Post => Game'Old.Round + 1 = Game.Round;
   function Play_Until (Players : in Positive;
      Last_Marble               : in Positive) return Score_Count;
end Marble_Mania;
