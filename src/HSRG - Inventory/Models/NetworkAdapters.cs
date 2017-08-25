using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("NetworkAdapters")]
    public class NetworkAdapters
    {
        [Key]
        public string ComputerID { get; set; }
        [Key]
        public string Name { get; set; }
        public string Manufacturer { get; set; }
        public string Description { get; set; }
        public string AdapterType { get; set; }
        public string Speed { get; set; }
        public string MACAddress { get; set; }
        public string NetConnectionID { get; set; }


    }
}