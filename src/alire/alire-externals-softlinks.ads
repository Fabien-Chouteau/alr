with Alire.Interfaces;
with Alire.TOML_Adapters;

with TOML;

package Alire.Externals.Softlinks is

   --  A do-nothing external that is used to use a dir as an in-progress crate.
   --  This external provides its path to be used for GPR_INCLUDE_PATH.

   type External (<>) is
     new Externals.External
     and Interfaces.Tomifiable
   with private;

   function New_Softlink (From : URL) return External;

   overriding
   function Detect (This        : External;
                    Unused_Name : Crate_Name) return Containers.Release_Set
   is (Containers.Release_Sets.Empty_Set);
   --  Never detected, as we want these crates to work as a wildcard for any
   --  version.

   function Is_Valid (This : External) return Boolean;
   --  Check that the pointed-to folder exists

   overriding
   function Image (This : External) return String;

   overriding
   function Detail (This          : External;
                    Unused_Distro : Platforms.Distributions)
                    return Utils.String_Vector
   is (Utils.Empty_Vector.Append ("User-provided external crate"));

   overriding
   function Kind (This : External) return String is ("Symbolic link");

   function Project_Paths (This : External) return Utils.String_Vector;
   --  For now it returns the root path given by the user. We could consider
   --  adding more paths at configuration time.

   function Path (This : External) return Any_Path;

   function From_TOML (Table : TOML_Adapters.Key_Queue) return External;

   overriding
   function To_TOML (This : External) return TOML.TOML_Value;

private

   type External (Path_Length : Positive) is
     new Externals.External
     and Interfaces.Tomifiable with record
      Path : Any_Path (1 .. Path_Length);
   end record;

   -----------
   -- Image --
   -----------

   overriding
   function Image (This : External) return String
   is ("User-provided at " & This.Path);

   --------------
   -- Is_Valid --
   --------------

   function Is_Valid (This : External) return Boolean
   is (GNAT.OS_Lib.Is_Directory (This.Path));

   ----------
   -- Path --
   ----------

   function Path (This : External) return Any_Path
   is (This.Path);

   -------------------
   -- Project_Paths --
   -------------------

   function Project_Paths (This : External) return Utils.String_Vector
   is (Utils.To_Vector (This.Path));

end Alire.Externals.Softlinks;
