using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("UpdatesInstalled")]
    public class UpdatesInstalled
    {
        [Key]
        public string ComputerID { get; set; }
        [Key]
        public string HotFixID { get; set; }
        public string Description { get; set; }
        public string InstalledBy { get; set; }
        public string InstalledOn { get; set; }

    }
}