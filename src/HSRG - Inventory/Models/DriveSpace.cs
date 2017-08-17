using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("DriveSpace")]
    public class DriveSpace
    {
        [Key]
        public string ComputerID { get; set; }
        [Column("Drive Letter")]
        public string DriveLetter { get; set; }
        public string Label { get; set; }
        [Column("Free Space - GB")]
        public string FreeSpaceGB { get; set; }
        [Column("Total Space - GB")]
        public string TotalSpaceGB { get; set; }

    }
}