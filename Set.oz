% Simple set operations

% Authors: Peter Van Roy and Seif Haridi
% May 9, 2003

% This is the Set module, which defines operations on sets
% represented as unordered lists.  The operations are set union
% (Union), set intersection (Inter), and set difference (Minus).
% These operations take time proportional to the product of the
% argument sizes.  They work with sets of any values represented
% as lists containing the values in any order.

functor
export
   union:Union inter:Inter minus:Minus
define
   fun {Union L1 L2}
      case L1 of nil then L2
      [] H1|T1 then
         if {Member H1 L2} then {Union T1 L2}
         else H1|{Union T1 L2} end
      end
   end

   fun {Inter L1 L2}
      case L1 of nil then nil
      [] H1|T1 then
         if {Member H1 L2} then H1|{Inter T1 L2}
         else {Inter T1 L2} end
      end
   end

   fun {Minus L1 L2}
      case L1 of nil then nil
      [] H1|T1 then
         if {Member H1 L2} then {Minus T1 L2}
         else H1|{Minus T1 L2} end
      end
   end
end

