public class OasisSecurity {
    public class Password_element {
        public String Type_x;
        private String[] Type_x_att_info = new String[]{'Type'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class TimeStamp {
        public DateTime Created;
        public DateTime Expires;
        private String[] Created_type_info = new String[]{'Created','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] Expires_type_info = new String[]{'Expires','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'Created','Expires'};
    }
    public class UsernameToken {
        public String Username;
        public OasisSecurity.Password_element Password;
        private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','Password_element','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'Username','Password'};
    }
    public class SecurityHeaderType {
        public OasisSecurity.UsernameToken UsernameToken;
        public OasisSecurity.TimeStamp TimeStamp;
        private String[] UsernameToken_type_info = new String[]{'UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','1','1','false'};
        private String[] TimeStamp_type_info = new String[]{'TimeStamp','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','TimeStamp','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'UsernameToken','TimeStamp'};
    }
}