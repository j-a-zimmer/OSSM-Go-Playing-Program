functor
   import Pickle Browser
define
   Loaded = {Pickle.load 'genome'}
   
   {Browser.browse Loaded.last}
   {Browser.browse Loaded.current}
end
