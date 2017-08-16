using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;


namespace HSRG___Inventory.Models
{
    [Table("SystemInformation")]
    public class SystemInformation
    {
        [Key]
        public string ComputerID { get; set; }
        public string Vendor { get; set; }
        public string Version { get; set; }
        public string Name { get; set; }
        public string IdentifyingNumber { get; set; }
        public string UUID { get; set; }

    }
}