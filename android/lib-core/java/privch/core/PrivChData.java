package privch.core;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import privch.core.data.Converter;
import privch.core.data.Shadowsocks;
import privch.core.data.ShadowsocksDao;
import privch.core.data.Statistic;
import privch.core.data.StatisticDao;

/**
 * 2021-04
 */
@Database(entities = {Shadowsocks.class, Statistic.class}, version = 1)
@TypeConverters({Converter.class})
public abstract class PrivChData extends RoomDatabase {
    public abstract ShadowsocksDao shadowsocksDao();
    public abstract StatisticDao statisticDao();

    // single instance -----------------------------------------------------------------------------
    public static PrivChData getInstance() {
        return database;
    }

    /**
     * single instance.
     */
    public static void create(@NonNull Context appContext, @NonNull String dbPath) {
        if (database == null) {
            database = Room.databaseBuilder(appContext, PrivChData.class, dbPath).build();
        }
    }

    public static void dispose() {
        if (database != null) {
            database.close();
            database = null;
        }
    }

    private static PrivChData database;
}
