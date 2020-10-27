public class PL
    {
        public static final string NONE = '--None--';
        public PL()
        {
            selection = null;
            options = new List<SelectOption>();
            selections = null;
        }
        
        public string selection
        {
            get
            {
                if (selection == NONE)
                {
                    return null;
                }
                else
                {
                    return selection;
                }
            }
            set;
        }
        
        public List<string> selections
        {
            get
            {
                return selections;
            }
            set;
        }
        
        public List<SelectOption> options
        {
            get
            {
                return options;
                /*if (options == null || options.size() == 0)
                {
                    List<selectoption> nonePickLIst = new List<SelectOption>();
                    nonePickList.add(new selectoption(NONE, NONE));
                    return nonePickList;
                } 
                else
                {
                    if (options[0].getLabel() != NONE)
                    {
                        options.add(0, new SElectoption(NONE, NONE));
                    }
                    return options;
                }*/
            }
            
            set;
        }
        public void defaultSelection()
        {
            if (options.size() == 0)
            {
                selection = null;
            }
            else
            {
                selection = options[0].getValue();
            }
        }
        
        public string firstOptionValue
        {
            get
            {
                if (options.size() == 0)
                {
                    return null; 
                }
                else
                {
                    if (options[0].getValue() == NONE)
                    {
                        return null;
                    }
                    else
                    {
                        return options[0].getValue();
                    }
                }
            }
        }
        public void defaultNonNoneValue()
        {
            if (options.size() > 1)
            {
                selection = options[1].getValue();  
            }
        }
        public void addNoneOption()
        {
            if (options.size() == 0)
            {
                options.add(new SelectOption(NONE, NONE));
            }
            else
            {
                options.add(0, new SelectOption(NONE, NONE));
            }
        }
        public static SelectOption noneOption
        {
            get
            {
                return new SelectOption(NONE, NONE);
            }
        }
        
    }